import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Intervention } from './entities/intervention.entity';
import { CreateInterventionDto } from './dto/create-intervention.dto';
import { UpdateInterventionDto } from './dto/update-intervention.dto';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';

@Injectable()
export class InterventionService {
  constructor(
    @InjectRepository(Intervention)
    private readonly interventionRepository: Repository<Intervention>,
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: Repository<Vehicle>,
  ) {}

  // Método para crear una intervención
  async create(createInterventionDto: CreateInterventionDto){
    const { vehicle_id } = createInterventionDto;

    // Verifica si el vehículo existe
    const vehicle = await this.vehicleRepository.findOne({ where: { id_vehicle: vehicle_id } });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    // Crea y guarda la intervención
    const intervention = this.interventionRepository.create({ ...createInterventionDto, vehicle });
    const savedIntervention = await this.interventionRepository.save(intervention);

    // Mensaje de éxito al crear
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
    const result = await this.interventionRepository.delete(id);

    if (result.affected === 0) {
      throw new NotFoundException('Intervention not found');
    }

    return { message: 'Intervention successfully deleted' };
  }
}
