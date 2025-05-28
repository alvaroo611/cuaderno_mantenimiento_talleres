import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { InterventionDetailsService } from './intervention_details.service';
import { CreateInterventionDetailsDto } from './dto/create-intervention_details.dto';


@Controller('intervention-details')
export class InterventionDetailsController {
  constructor(private readonly interventionDetailsService: InterventionDetailsService) {}

  @Post()
  create(@Body() dto: CreateInterventionDetailsDto) {
    return this.interventionDetailsService.create(dto);
  }

  @Get()
  findAll() {
    return this.interventionDetailsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.interventionDetailsService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: Partial<CreateInterventionDetailsDto>) {
    return this.interventionDetailsService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.interventionDetailsService.remove(id);
  }
}
