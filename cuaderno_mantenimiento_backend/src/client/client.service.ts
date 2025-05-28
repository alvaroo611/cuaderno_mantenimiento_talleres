// src/client/client.service.ts
import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Client } from './entities/client.entity';
import { CreateClientDto } from './dto/create-client.dto';
import { Person } from 'src/person/entities/person.entity';
import * as bcrypt from 'bcrypt';
@Injectable()
export class ClientService {
  constructor(
    @InjectRepository(Client)
    private readonly clientRepository: Repository<Client>,
    @InjectRepository(Person)
    private readonly personRepository: Repository<Person>, // Servicio de Persona para crear la persona asociada
  ) {}

  // Crear un nuevo cliente
  async create(createClientDto: CreateClientDto){
    const { nombre,correo,password, ...clientData } = createClientDto;
      const isValidPassword = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(password);
     if (!isValidPassword) {
       throw new BadRequestException({
         message: 'The password must be at least 6 characters and include letters and numbers.',
       });
     }
    const hashedPassword = await this.hashPassword(password);
    //Modificamos los campos de `person` antes de crear la persona
    const modifiedPersonData = {
      nombre:nombre, 
      correo:correo, 
      password: hashedPassword, 
      rol:'client'
    };

    // Validación de si ya existe una persona con el mismo correo
    const existingCorreo = await this.personRepository.findOne({
      where: { correo: modifiedPersonData.correo },
    });

    if (existingCorreo) {
      throw new ConflictException('Ya existe una persona con ese correo.');
    }

    const existingPhone = await this.clientRepository.findOne({
        where: { telefono:clientData.telefono },
      });
  
      if (existingPhone) {
        throw new ConflictException('Ya existe una persona con ese teléfono.');
      }
  

    // Crear la persona asociada al cliente con los datos modificados
    const newPerson = this.personRepository.create(modifiedPersonData); // Crear la persona con los datos modificados

    // Guardar la persona en la base de datos
    const savedPerson = await this.personRepository.save(newPerson);

    // Crear el cliente y asociar la persona recién creada
    const client = this.clientRepository.create({
      ...clientData,
      persona: savedPerson, // Asociamos la persona al cliente
    });
    await this.clientRepository.save(client);
    // Guardar el cliente
    return {message:'Successfully created client.'}
  }

  // Función para encriptar la contraseña 
  private async hashPassword(password: string): Promise<string> {
   
    
    return await bcrypt.hash(password, 10);;
  }

  // Obtener todos los clientes
  async findAll(): Promise<Client[]> {
    return await this.clientRepository.find({ relations: ['persona', 'vehicles'] });
  }

  // Obtener un cliente por ID
  async findOne(id_client: string): Promise<Client> {
    const client = await this.clientRepository.findOne({
      where: { id_client },
      relations: ['persona', 'vehicles'],
    });
    if (!client) {
      throw new NotFoundException(`Client with ID ${id_client} not found`);
    }
    return client;
  }

  async update(id_client: string, updateClientDto: CreateClientDto) {
     console.log('[UPDATE CLIENT] DTO recibido:', updateClientDto,'id: ',id_client);
    const { nombre, correo, password, telefono, ...clientData } = updateClientDto;

    // Verificar si el cliente existe
    const client = await this.clientRepository.findOne({
      where: { id_client },
      relations: ['persona'], // Asegúrate de cargar la relación de la persona
    });

    if (!client) {
      throw new NotFoundException(`Client with ID ${id_client} not found`);
    }

    // Validación de contraseña (si se actualiza)
    if (password) {
      const isValidPassword = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(password);
      if (!isValidPassword) {
        throw new BadRequestException({
          message: 'The password must be at least 6 characters and include letters and numbers.',
        });
      }
      // Encriptar la nueva contraseña si se proporciona
      client.persona.password = await this.hashPassword(password);
    }

    // Validación de correo (si se actualiza)
    if (correo && correo !== client.persona.correo) {
      const existingCorreo = await this.personRepository.findOne({
        where: { correo },
      });
      if (existingCorreo) {
        throw new ConflictException('Ya existe una persona con ese correo.');
      }
      client.persona.correo = correo; // Actualizamos el correo
    }

    // Validación de teléfono (si se actualiza)
    if (telefono && telefono !== client.telefono) {
      const existingPhone = await this.clientRepository.findOne({
        where: { telefono },
      });
      if (existingPhone) {
        throw new ConflictException('Ya existe una persona con ese teléfono.');
      }
      client.telefono = telefono; // Actualizamos el teléfono
    }

    // Actualizar la persona asociada al cliente
    client.persona.nombre = nombre || client.persona.nombre;
    client.persona.rol ='client';

    // Actualizar los datos del cliente
    client.domicilio = clientData.domicilio || client.domicilio;
    client.localidad = clientData.localidad || client.localidad;
    client.provincia = clientData.provincia || client.provincia;
    client.codigo_postal = clientData.codigo_postal || client.codigo_postal;

    // Guardar los cambios en la base de datos
    await this.personRepository.save(client.persona);
    await this.clientRepository.save(client);
    return {message:'Client updated sucefully.'}
  }
 

  // Eliminar un cliente
  async remove(id_client: string) {
    const client = await this.findOne(id_client);
    await this.clientRepository.remove(client);
    return {message:'Client delete sucefully.'};
  }
}
