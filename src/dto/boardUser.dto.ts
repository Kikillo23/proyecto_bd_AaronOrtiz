import { IsUUID, IsBoolean, IsNotEmpty } from "class-validator";

export class BoardUser {
    @IsUUID()
    @IsNotEmpty()
    board_id: string;
  
    @IsUUID()
    @IsNotEmpty()
    user_id: string;
  
    @IsBoolean()
    is_admin: boolean;
}