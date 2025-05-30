import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Intervention } from './entities/intervention.entity';
import { CreateInterventionDto } from './dto/create-intervention.dto';
import { UpdateInterventionDto } from './dto/update-intervention.dto';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { InterventionDetails } from 'src/intervention_details/entities/intervention_details.entity';

@Injectable()
export class InterventionService {
  constructor(
    @InjectRepository(Intervention)
    private readonly interventionRepository: Repository<Intervention>,
     @InjectRepository(InterventionDetails)
    private readonly interventionDetailRepository: Repository<InterventionDetails>,
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: Repository<Vehicle>,
  ) {}

  // Método para crear una intervención
  async create(createInterventionDto: CreateInterventionDto) {
  console.log('➡️ Iniciando creación de intervención...');
  console.log('📦 DTO recibido:', createInterventionDto);

  const { vehicle_id } = createInterventionDto;
  console.log('🔍 Buscando vehículo con ID:', vehicle_id);

  // Verifica si el vehículo existe
  const vehicle = await this.vehicleRepository.findOne({ where: { id_vehicle: vehicle_id } });
  console.log('🚗 Vehículo encontrado:', vehicle);

  if (!vehicle) {
    console.log('❌ Vehículo no encontrado');
    throw new NotFoundException('Vehicle not found');
  }

  // Crea y guarda la intervención
  const intervention = this.interventionRepository.create({ ...createInterventionDto, vehicle });
  console.log('🛠️ Intervención creada (sin guardar):', intervention);

  const savedIntervention = await this.interventionRepository.save(intervention);
  console.log('💾 Intervención guardada:', savedIntervention);

  // Mensaje de éxito al crear
  console.log('✅ Intervención creada con éxito');

  return {
    message: 'Intervention successfully created',
    intervention: savedIntervention,
  };
}


  // Método para obtener todas las intervenciones
  async findAll(): Promise<Intervention[]> {
    const interventions = await this.interventionRepository.find({ relations: ['vehicle','details'] });
    return interventions ;
  }
  async findByVehicleId(vehicleId: string): Promise<Intervention[]> {
  const vehicle = await this.vehicleRepository.findOne({ where: { id_vehicle: vehicleId } });
  if (!vehicle) {
    throw new NotFoundException('Vehicle not found');
  }

  const interventions = await this.interventionRepository.find({
    where: { vehicle: { id_vehicle: vehicleId } },
    relations: ['vehicle', 'details'],  // incluir relaciones necesarias
  });

  return interventions;
}
  async getFullInterventionInfo(interventionId: string) {
  const intervention = await this.interventionRepository.findOne({
    where: { id_intervencion: interventionId },
    relations: ['vehicle', 'details'],
  });

  if (!intervention) {
    throw new NotFoundException('Intervention not found');
  }

  const vehicle = intervention.vehicle;

  return {
    vehicle: {
      proximaRevisionFecha: vehicle.proxima_revision_fecha,
      kilometrajeEstimadoRevision: vehicle.kilometraje_estimado_revision,
    },
    intervention: {
      fecha: intervention.fecha,
      kilometraje: intervention.kilometraje,
      tipoIntervencion: intervention.tipo_intervencion,
      observaciones: intervention.observaciones,
    },
    detalles: intervention.details.map((detail) => ({
      id_intervention_details:detail.id_intervention_details,
      elemento: detail.elemento,
      estado: detail.estado,
      marca: detail.marca,
    })),
  };
}

  // Método para obtener una intervención específica
  async findOne(id: string): Promise<Intervention > {
    const intervention = await this.interventionRepository.findOne({
      where: { id_intervencion: id },
      relations: ['vehicle','details'],
    });

    if (!intervention) {
      throw new NotFoundException('Intervention not found');
    }

    return intervention ;
  }

  // Método para actualizar una intervención
  async update(id: string, updateInterventionDto: UpdateInterventionDto): Promise<{ message: string; intervention: Intervention }> {
    const intervention = await this.interventionRepository.preload({
      id_intervencion: id,
      ...updateInterventionDto,
    });

    if (!intervention) {
      throw new NotFoundException('Intervention not found');
    }

    const updatedIntervention = await this.interventionRepository.save(intervention);
    return { message: 'Intervention successfully updated', intervention: updatedIntervention };
  }

  // Método para eliminar una intervención
  async remove(id: string): Promise<{ message: string }> {
    // Buscar intervención para comprobar que existe
    const intervention = await this.interventionRepository.findOne({ where: { id_intervencion: id } });
    if (!intervention) {
      throw new NotFoundException('Intervention not found');
    }

    // Eliminar todos los detalles asociados a la intervención
    await this.interventionDetailRepository.delete({ intervention: { id_intervencion: id } });

    // Eliminar la intervención
    await this.interventionRepository.delete(id);

    return { message: 'Intervention and its details successfully deleted' };
  }
}
