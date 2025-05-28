import { Module } from '@nestjs/common';


import { PersonController } from './person.controller';
import { PersonService } from './person.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Person } from './entities/person.entity';
import { JwtModule } from '@nestjs/jwt';



@Module({
  controllers: [PersonController],
  providers: [PersonService],
  imports:[JwtModule.register({
          secret: process.env.JWT_SECRET, // Lee la clave secreta desde las variables de entorno
          signOptions: { expiresIn: '1h' },
        }), TypeOrmModule.forFeature([Person])],

})

export class PersonModule {}
