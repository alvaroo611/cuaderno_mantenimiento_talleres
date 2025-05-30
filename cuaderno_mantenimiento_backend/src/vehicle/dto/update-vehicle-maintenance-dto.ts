import { IsDateString, IsNumber, IsOptional } from 'class-validator';

export class UpdateVehicleMaintenanceDto {
  @IsOptional()
  @IsDateString()
  proxima_revision_fecha?: string;

  @IsOptional()
  @IsNumber()
  kilometraje_estimado_revision?: number;
}