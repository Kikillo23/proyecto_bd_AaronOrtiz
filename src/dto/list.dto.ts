import { IsString, IsUUID, IsNotEmpty, IsDateString } from "class-validator";

export class List {
    @IsString()
    @IsNotEmpty()
    name: string;
  
    @IsUUID()
    board_id: string;
  }