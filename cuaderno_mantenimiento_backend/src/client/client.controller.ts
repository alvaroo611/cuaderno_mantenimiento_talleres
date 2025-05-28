import { Controller, Get, Post, Patch, Param, Body, Delete } from '@nestjs/common';
import { ClientService } from './client.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';

@Controller('clients')
export class ClientController {
  constructor(private readonly clientService: ClientService) {}

  @Post()
  async create(@Body() createClientDto: CreateClientDto) {
    return this.clientService.create(createClientDto);
  }

  @Get()
  async findAll() {
    return this.clientService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id_client: string) {
    return this.clientService.findOne(id_client);
  }

  @Patch(':id') // Usamos PATCH para actualizaciones parciales
  async update(
    @Param('id') id_client: string, // El ID del cliente que queremos actualizar
    @Body() updateClientDto: CreateClientDto, // Usamos CreateClientDto o un DTO de actualización
  ) {
    return this.clientService.update(id_client, updateClientDto);
  }


  @Delete(':id')
  async remove(@Param('id') id_client: string) {
    return this.clientService.remove(id_client);
  }
}
