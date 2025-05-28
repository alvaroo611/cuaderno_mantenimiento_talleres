import { Controller, Get, Post, Delete, Body, Param, NotFoundException, Patch } from '@nestjs/common';
import { PersonService } from './person.service';
import { CreatePersonDto } from './dto/create-person.dto';
import { Person } from './entities/person.entity';
import { UpdatePersonDto } from './dto/update-person.dto';
import { LoginDto } from './dto/login-person.dto';

@Controller('person')
export class PersonController {
  constructor(private readonly personService: PersonService) {}

  // Endpoint para crear una nueva persona
  @Post()
  async create(@Body() createPersonDto: CreatePersonDto): Promise<{ message: string }> {
     
    return this.personService.register(createPersonDto);
  }
  
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    console.log('DTO recibido:', loginDto);
    return this.personService.login(loginDto);
  }
  // Endpoint para obtener todas las personas
  @Get()
  async findAll(): Promise<Person[]> {
    return this.personService.findAll();
  }

  // Endpoint para obtener una persona por ID
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Person> {
    return this.personService.findOne(id);
  }
  @Patch(':id')
  async update(
    @Param('id') id_person: string,
    @Body() updatePersonDto: UpdatePersonDto
  ): Promise<{ message: string }> {
    return this.personService.update(id_person, updatePersonDto);
  }


  // Endpoint para eliminar una persona por ID
  @Delete(':id')
  async remove(@Param('id') id: string): Promise<{ message: string }> {
    const person = await this.personService.findOne(id);
    if (!person) {
      throw new NotFoundException(`Person with ID ${id} not found`);
    }
    await this.personService.remove(id);
    return { message: 'Person deleted successfully' };
  }
}