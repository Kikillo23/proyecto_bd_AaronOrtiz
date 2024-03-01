import { IsUUID, IsBoolean, IsNotEmpty } from "class-validator";

export class CardUser {
    @IsUUID()
    @IsNotEmpty()
    card_id: string;
  
    @IsUUID()
    @IsNotEmpty()
    user_id: string;
  
    @IsBoolean()
    is_owner: boolean;
}