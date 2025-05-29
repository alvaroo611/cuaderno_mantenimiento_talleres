import { Module } from '@nestjs/common';

import { TypeOrmModule } from '@nestjs/typeorm';

import { InterventionController } from './intervention.controller';
import { InterventionService } from './intervention.service';
import { Intervention } from './entities/intervention.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { InterventionDetails } from 'src/intervention_details/entities/intervention_details.entity';



@Module({
  controllers: [InterventionController],
  providers: [InterventionService],
  imports:[ TypeOrmModule.forFeature([Vehicle,Intervention,InterventionDetails])],

})

export class InterventionModule {}
