import { Module } from '@nestjs/common';
import { VehicleController } from './vehicle.controller';
import { VehicleService } from './vehicle.service';
import { Vehicle } from './entities/vehicle.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Client } from 'src/client/entities/client.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';
import { InterventionDetails } from 'src/intervention_details/entities/intervention_details.entity';



@Module({
  controllers: [VehicleController],
  providers: [VehicleService],
  imports:[ TypeOrmModule.forFeature([Vehicle,Client,Intervention,InterventionDetails])],

})

export class VehicleModule {}
