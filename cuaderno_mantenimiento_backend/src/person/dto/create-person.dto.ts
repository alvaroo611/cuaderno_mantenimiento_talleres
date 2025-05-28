// src/dto/create-person.dto.ts
import { IsString, IsEmail, IsIn } from 'class-validator';

export class CreatePersonDto {
  @IsString()
  nombre: string;

  @IsEmail()
  correo: string;

  @IsString()
  password: string;

  @IsString()
  @IsIn(['admin', 'client'])
  rol: string;
}
