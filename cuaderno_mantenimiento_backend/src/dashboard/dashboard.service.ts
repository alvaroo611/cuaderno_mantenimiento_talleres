// src/dashboard/dashboard.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Client } from 'src/client/entities/client.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';
import { Repository, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import * as dayjs from 'dayjs';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Client)
    private clientRepository: Repository<Client>,

    @InjectRepository(Vehicle)
    private vehicleRepository: Repository<Vehicle>,

    @InjectRepository(Intervention)
    private interventionRepository: Repository<Intervention>,
  ) {}

  async getStatistics() {
    const today = dayjs();
    const startOfWeek = today.startOf('week').format('YYYY-MM-DD');
    const endOfWeek = today.endOf('week').format('YYYY-MM-DD');
    const now = today.format('YYYY-MM-DD');

    const totalClients = await this.clientRepository.count();
    const totalVehicles = await this.vehicleRepository.count();
    const interventionsThisWeek = await this.interventionRepository.count({
      where: {
        fecha: MoreThanOrEqual(startOfWeek) && LessThanOrEqual(endOfWeek),
      },
    });
    const upcomingRevisions = await this.vehicleRepository.count({
      where: {
        proxima_revision_fecha: MoreThanOrEqual(now),
      },
    });
    const latestInterventions = await this.interventionRepository.find({
      order: { fecha: 'DESC' },
      take: 5,
    });

    return {
      totalClients,
      totalVehicles,
      interventionsThisWeek,
      upcomingRevisions,
      latestInterventions,
    };
  }
}
