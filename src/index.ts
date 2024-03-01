import { plainToClass } from "class-transformer";
import { validateOrReject } from "class-validator";
import dotenv from "dotenv";
import "es6-shim";
import express, { Express, Request, Response } from "express";
import { Pool } from "pg";
import "reflect-metadata";
import { Board } from "./dto/board.dto";
import { User } from "./dto/user.dto";
import { List } from "./dto/list.dto";
import { Card } from "./dto/card.dto";
import { CardUser } from "./dto/cardUser.dto";

dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: +process.env.DB_PORT!,
});

const app: Express = express();
const port = process.env.PORT || 3000;
app.use(express.json());

app.get("/users", async (req: Request, res: Response) => {
  try {
    const text = "SELECT id, name, email FROM users";
    const result = await pool.query(text);
    res.status(200).json(result.rows);
  } catch (errors) {
    return res.status(400).json(errors);
  }
});

app.post("/users", async (req: Request, res: Response) => {
  let userDto: User = plainToClass(User, req.body);
  try {
    await validateOrReject(userDto);

    const text = "INSERT INTO users(name, email) VALUES($1, $2) RETURNING *";
    const values = [userDto.name, userDto.email];
    const result = await pool.query(text, values);
    res.status(201).json(result.rows[0]);
  } catch (errors) {
    return res.status(422).json(errors);
  }
});

app.get("/boards", async (req: Request, res: Response) => {
  try {
    const text =
      'SELECT boards.id, boards.name, board_users.user_id AS "adminUserId" FROM boards JOIN board_users ON board_users.board_id = boards.id WHERE board_users.is_admin IS true';
    const result = await pool.query(text);
    res.status(200).json(result.rows);
  } catch (errors) {
    return res.status(400).json(errors);
  }
});

app.post("/boards", async (req: Request, res: Response) => {
  const client = await pool.connect();
  try {
    const userId = req.headers['user-id'] as string;
    if (!userId) {
      return res.status(401).json({message: 'User not authenticated'});
    }
    let boardDto: Board = plainToClass(Board, {...req.body, adminUserId: userId});

    client.query("BEGIN");
    await validateOrReject(boardDto, {});

    const boardText = "INSERT INTO boards(name) VALUES($1) RETURNING *";
    const boardValues = [boardDto.name];
    const boardResult = await client.query(boardText, boardValues);

    const boardUserText =
      "INSERT INTO board_users(board_id, user_id, is_admin) VALUES($1, $2, $3)";
    const boardUserValues = [
      boardResult.rows[0].id,
      boardDto.adminUserId,
      true,
    ];
    await client.query(boardUserText, boardUserValues);

    client.query("COMMIT");
    res.status(201).json(boardResult.rows[0]);
  } catch (errors) {
    client.query("ROLLBACK");
    return res.status(422).json(errors);
  } finally {
    client.release();
  }
});

app.get("/getListByBoard", async (req: Request, res: Response) => {
  try {
    const boardId: String = req.query.id as string;

    // Utiliza consultas parametrizadas
    const text = "SELECT list.id, list.name, list.board_id FROM list WHERE list.board_id = $1";

    // Pasa los parámetros como un array en la función query
    const result = await pool.query(text, [boardId]);
    res.status(200).json(result.rows);
  } catch (errors) {
    console.log({errors});
    return res.status(400).json(errors);
  }
});

app.post("/createListForBoard", async (req: Request, res: Response) => {

  let listDto: List = plainToClass(List, req.body);
  try {
    await validateOrReject(listDto);

    const text = "INSERT INTO list(name, board_id) VALUES($1, $2) RETURNING *";
    const values = [listDto.name, listDto.board_id];
    const result = await pool.query(text, values);
    res.status(201).json(result.rows[0]);
  } catch (errors) {
    return res.status(422).json(errors);
  }
});

app.post("/createCardForList", async (req: Request, res: Response) => {

  let cardDto: Card = plainToClass(Card, req.body);
  let userId: String = req.headers['user-id'] as string;
  try {
    await validateOrReject(cardDto);

    const validUser = await pool.query('SELECT * FROM list WHERE list.id = $1 AND list.board_id IN (SELECT board_id FROM board_users WHERE user_id = $2)', [cardDto.list_id, userId]);

    if(validUser.rows.length === 0) {
      return res.status(403).json({message: 'User not allowed to create card in this list'});
    }

    const text = "INSERT INTO cards(title, description, due_date, list_id) VALUES($1, $2, $3, $4) RETURNING *";
    const values = [cardDto.title, cardDto.description, cardDto.due_date, cardDto.list_id];
    const result = await pool.query(text, values);
    res.status(201).json(result.rows[0]);
  } catch (errors) {
    return res.status(422).json(errors);
  }
});

/*
  This method include the user name in the response
*/
app.get("/getCardsByList", async (req: Request, res: Response) => {
  try {
    const listId: String = req.query.id as string;

    // Utiliza consultas parametrizadas
    const text = 'SELECT cards.*, users.name AS user_name FROM cards JOIN list ON cards.list_id = list.id JOIN board_users ON list.board_id = board_users.board_id JOIN users ON board_users.user_id = users.id WHERE list.id = $1';

    const result = await pool.query(text, [listId]);
    res.status(200).json(result.rows);
  } catch (errors) {
    return res.status(400).json(errors);
  }
});

/*
  This method assign a user to a card
*/
app.post("/assignUserToCard", async (req: Request, res: Response) => {
  let cardId: String = req.body.card_id;
  let userId: String = req.body.user_id;
  try {
    const validUser = await pool.query(`SELECT 
                                          * 
                                        FROM cards 
                                        JOIN list 
                                          ON cards.list_id = list.id 
                                        JOIN board_users 
                                          ON list.board_id = board_users.board_id 
                                        WHERE 
                                          cards.id = $1 
                                          AND 
                                          board_users.user_id = $2
    `, [cardId, userId]);

    if(validUser.rows.length === 0) {
      return res.status(403).json({message: 'User not allowed to assign to this card'});
    }

    const text = "INSERT INTO card_users(user_id, card_id, is_owner) VALUES($1, $2, true) RETURNING *";
    const values = [userId, cardId];
    const result = await pool.query(text, values);
    res.status(200).json(result.rows[0]);
  } catch (errors) {
    return res.status(422).json(errors);
  }
});

app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
});
