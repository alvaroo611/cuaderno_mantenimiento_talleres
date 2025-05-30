import { Controller, Get, Post, Body, Patch, Param, Delete, InternalServerErrorException } from '@nestjs/common';

import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { VehicleService } from './vehicle.service';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { UpdateVehicleMaintenanceDto } from './dto/update-vehicle-maintenance-dto';


@Controller('vehicle')
export class VehicleController {
  constructor(private readonly vehicleService: VehicleService) {}

  @Post()
  async create(@Body() createVehicleDto: CreateVehicleDto) {
    return await this.vehicleService.create(createVehicleDto);
  }

  @Get()
  async findAll() {
    return await this.vehicleService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.vehicleService.findOne(id);
  }
  @Get('client/:clientId')
  async getVehiclesByClientId(@Param('clientId') clientId: string) {
    return await this.vehicleService.findByClientId(clientId);
  }
 @Patch(':id')
  async update(
    @Param('id') id_vehicle: string,
    @Body() updateVehicleDto: UpdateVehicleDto
  ) {
    console.log('🔧 [PATCH /:id] ID recibido por parámetro:', id_vehicle);
    console.log('📥 [PATCH /:id] Body recibido:', updateVehicleDto);

    try {
      const updatedVehicle = await this.vehicleService.update(id_vehicle, updateVehicleDto);
      console.log('✅ Vehículo actualizado correctamente:', updatedVehicle);
      return updatedVehicle;
    } catch (error) {
      console.error('❌ Error actualizando vehículo:', error);
      // Opcional: puedes lanzar una excepción HTTP para que el cliente reciba el error
      throw new InternalServerErrorException('Error al actualizar vehículo');
    }
  }
  @Patch(':id_vehicle/maintenance')
  async updateMaintenance(
    @Param('id_vehicle') id: string,
    @Body() updateDto: UpdateVehicleMaintenanceDto,
  ) {
    return this.vehicleService.updateMaintenanceFields(id, updateDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.vehicleService.remove(id);
  }
}
