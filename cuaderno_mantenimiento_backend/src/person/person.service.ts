// src/person/person.service.ts
import { BadRequestException, ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Person } from './entities/person.entity';
import { CreatePersonDto } from './dto/create-person.dto';
import * as bcrypt from 'bcrypt';
import { UpdatePersonDto } from './dto/update-person.dto';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from './dto/login-person.dto';
@Injectable()
export class PersonService {
  constructor(
    @InjectRepository(Person)
    private readonly personRepository: Repository<Person>,
    private jwtService: JwtService,
  ) {}



  async login(loginDto: LoginDto) {
    const { correo, password } = loginDto;

    // 1️⃣ Buscar usuario por correo
    const person = await this.personRepository.findOne({
      where: { correo },
    });

    if (!person) {
      throw new NotFoundException('User with this email does not exist.');
    }

    // 2️⃣ Verificar la contraseña con bcrypt
    const isPasswordValid = await bcrypt.compare(password, person.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid password.');
    }

    // 3️⃣ Crear el payload para el token JWT
    const payload = {
      sub: person.id_person, // Identificador único del usuario
      role: person.rol, // Rol del usuario
    };

    // 4️⃣ Generar el token JWT
    const access_token = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET, // Usa una variable de entorno
      expiresIn: '1h', // Token expira en 1 hora
    });

    return {
      access_token,
      message: 'Login successful',
      user: {
        id: person.id_person,
        nombre: person.nombre,
        correo: person.correo,
        rol: person.rol,
      },
    };
  }

  async register(createPersonDto: CreatePersonDto): Promise<{ message: string }> {
    const { nombre, correo, password, rol } = createPersonDto;

    // Verificar si el usuario ya existe
    const existingPerson = await this.personRepository.findOne({ where: { correo } });
    if (existingPerson) {
      throw new ConflictException('A user with this email already exists.');
    }

    // Validar el rol (solo admins pueden registrarse)
    if (rol !== 'admin') {
      throw new BadRequestException('Only users with the "admin" role can be registered.');
    }

    // Validar la contraseña (mínimo 6 caracteres, al menos una letra y un número)
    const isValidPassword = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(password);
    if (!isValidPassword) {
      throw new BadRequestException('The password must be at least 6 characters long and contain letters and numbers.');
    }

    // Cifrar la contraseña antes de guardarla
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear la nueva persona con la contraseña encriptada
    const person = this.personRepository.create({
      nombre,
      correo,
      password: hashedPassword,
      rol,
    });

    await this.personRepository.save(person);
    return { message: 'Successfully created admin user.' };
  }

  // Obtener todas las personas
  async findAll(): Promise<Person[]> {
    return await this.personRepository.find();
  }

  // Obtener una persona por id
  async findOne(id_person: string): Promise<Person> {
    const person = await this.personRepository.findOne({ where: { id_person } });
    
    if (!person) {
      throw new NotFoundException(`Admin not found`);
    }
    
    return person;
  }


  async update(id_person: string, updatePersonDto: UpdatePersonDto): Promise<{ message: string }> {
    const { nombre, correo, password, rol } = updatePersonDto;
  
    // Buscar la persona por ID
    const person = await this.personRepository.findOne({ where: { id_person } });
  
    if (!person) {
      throw new NotFoundException(`Admin not found`);
    }
  
    // Si se proporciona un nuevo correo, verificar que no esté en uso
    if (correo && correo !== person.correo) {
      const existingPerson = await this.personRepository.findOne({ where: { correo } });
      if (existingPerson) {
        throw new ConflictException('A user with this email already exists.');
      }
    }
    if (rol !== 'admin') {
      throw new BadRequestException('Users with the "admin" role cannot is client.');
    }
  
    // Validar la contraseña solo si se proporciona una nueva
    if (password) {
      const isValidPassword = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(password);
      if (!isValidPassword) {
        throw new BadRequestException('The password must be at least 6 characters long and contain letters and numbers.');
      }
  
      // Cifrar la nueva contraseña
      person.password = await bcrypt.hash(password, 10);
    }
  
    // Actualizar los valores de la entidad
    if (nombre) person.nombre = nombre;
    if (correo) person.correo = correo;
    if (rol) person.rol = rol;
  
    await this.personRepository.save(person);
    return { message: 'Admin updated successfully' };
  }
  
  // Eliminar una persona
  async remove(id: string): Promise<void> {
    await this.personRepository.delete(id);
  }
}
