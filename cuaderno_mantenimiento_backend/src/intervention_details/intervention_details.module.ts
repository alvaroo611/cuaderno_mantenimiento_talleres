import { Module } from '@nestjs/common';

import { TypeOrmModule } from '@nestjs/typeorm';

import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';
import { InterventionDetailsController } from './intervention_details.controller';
import { InterventionDetailsService } from './intervention_details.service';
import { InterventionDetails } from './entities/intervention_details.entity';



@Module({
  controllers: [InterventionDetailsController],
  providers: [InterventionDetailsService],
  imports:[ TypeOrmModule.forFeature([Intervention,InterventionDetails])],

})

export class InterventionDetailsModule {}
