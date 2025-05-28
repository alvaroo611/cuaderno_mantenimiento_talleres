import { Module } from '@nestjs/common';

import { TypeOrmModule } from '@nestjs/typeorm';

import { InterventionController } from './intervention.controller';
import { InterventionService } from './intervention.service';
import { Intervention } from './entities/intervention.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';



@Module({
  controllers: [InterventionController],
  providers: [InterventionService],
  imports:[ TypeOrmModule.forFeature([Vehicle,Intervention])],

})

export class InterventionModule {}
