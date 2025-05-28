import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';

import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { VehicleService } from './vehicle.service';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';


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
  async update(@Param('id') id_vehicle: string, @Body() updateVehicleDto: UpdateVehicleDto) {
    return await this.vehicleService.update(id_vehicle, updateVehicleDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.vehicleService.remove(id);
  }
}
