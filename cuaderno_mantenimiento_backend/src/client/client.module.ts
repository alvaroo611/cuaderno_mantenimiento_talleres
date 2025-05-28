import { Module } from '@nestjs/common';
import { ClientService } from './client.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Client } from './entities/client.entity';
import { Person } from 'src/person/entities/person.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { ClientController } from './client.controller';
import { JwtModule, JwtService } from '@nestjs/jwt';

@Module({
    imports: [TypeOrmModule.forFeature([Client,Person])],
    controllers: [ClientController],
    providers: [ClientService],
  })
  export class ClientModule {}
  