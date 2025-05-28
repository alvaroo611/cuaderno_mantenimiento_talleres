import { Controller, Get, Post, Body, Patch, Param, Delete, NotFoundException } from '@nestjs/common';
import { InterventionService } from './intervention.service';
import { CreateInterventionDto } from './dto/create-intervention.dto';
import { UpdateInterventionDto } from './dto/update-intervention.dto';

@Controller('intervention')
export class InterventionController {
  constructor(private readonly interventionService: InterventionService) {}

  @Post()
  async create(@Body() createInterventionDto: CreateInterventionDto) {
    return await this.interventionService.create(createInterventionDto);
  }

  @Get()
  async findAll() {
    return await this.interventionService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const intervention = await this.interventionService.findOne(id);
    if (!intervention) {
      throw new NotFoundException('Intervention not found');
    }
    return intervention;
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateInterventionDto: UpdateInterventionDto) {
    return await this.interventionService.update(id, updateInterventionDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.interventionService.remove(id);
  }
}
