import { IsUUID, IsDateString, IsNumber, IsString, IsOptional, IsNotEmpty, IsIn } from 'class-validator';

export class CreateInterventionDto {
  @IsNotEmpty()
  @IsDateString()
  fecha: string;

  @IsNotEmpty()
  @IsNumber()
  kilometraje: number;

  @IsNotEmpty()
  @IsString()
  @IsIn(['Revision', 'Cambio de pieza', 'Reparacion'], {
    message: 'tipo_intervencion must be either "Revision", "Cambio de pieza" or "Reparacion"',
  })
  tipo_intervencion: string;

  @IsOptional()
  @IsString()
  observaciones?: string;

  @IsNotEmpty()
  @IsUUID()
  vehicle_id: string; // Relación con Vehicle
}
