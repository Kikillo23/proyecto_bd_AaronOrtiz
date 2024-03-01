import { IsString, IsUUID, IsNotEmpty, IsDateString } from "class-validator";

export class Card {
    @IsString()
    @IsNotEmpty()
    title: string;
  
    @IsString()
    description: string;
  
    @IsDateString()
    due_date: string;
  
    @IsUUID()
    list_id: string;
  }