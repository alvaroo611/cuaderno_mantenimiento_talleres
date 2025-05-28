// src/dashboard/dashboard.module.ts
import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Client } from 'src/client/entities/client.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Client, Vehicle, Intervention])],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
