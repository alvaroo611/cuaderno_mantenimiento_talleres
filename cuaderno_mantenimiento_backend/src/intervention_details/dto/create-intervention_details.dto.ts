import { IsUUID, IsString, IsNotEmpty, IsOptional, IsIn } from 'class-validator';

export class CreateInterventionDetailsDto {
  @IsNotEmpty()
  @IsString()
  elemento: string;

  @IsNotEmpty()
  @IsString()
  @IsIn(['Bueno', 'Regular', 'Malo', 'Sustituido'], {
    message: 'status must be either "Bueno", "Regular", "Malo" or "Sustituido"',
  })
  estado: string;

  @IsOptional()
  @IsString()
  marca?: string;

  @IsNotEmpty()
  @IsUUID()
  intervention_id: string; 
}
