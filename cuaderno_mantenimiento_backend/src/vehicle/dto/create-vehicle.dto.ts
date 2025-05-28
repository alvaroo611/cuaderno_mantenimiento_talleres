import { IsString, IsUUID, IsOptional, IsDateString, IsNumber, IsNotEmpty } from 'class-validator';

export class CreateVehicleDto {
  @IsNotEmpty()
  @IsString()
  marca: string;

  @IsNotEmpty()
  @IsString()
  modelo: string;

  @IsNotEmpty()
  @IsString()
  bastidor: string;

  @IsNotEmpty()
  @IsString()
  tipo_motor: string;

  @IsNotEmpty()
  @IsString()
  matricula: string;

  @IsOptional()
  @IsDateString()
  proxima_revision_fecha?: string; // Fecha de próxima revisión (opcional)

  @IsOptional()
  @IsNumber()
  kilometraje_estimado_revision?: number; // Kilometraje estimado para la revisión (opcional)

  @IsNotEmpty()
  @IsUUID()
  client_id: string; // Relación con el cliente a través de su ID
}
