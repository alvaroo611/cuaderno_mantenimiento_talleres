import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { InterventionDetails } from './entities/intervention_details.entity';
import { CreateInterventionDetailsDto } from './dto/create-intervention_details.dto';
import { Intervention } from 'src/intervention/entities/intervention.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';


@Injectable()
export class InterventionDetailsService {
  constructor(
    @InjectRepository(InterventionDetails)
    private readonly interventionDetailsRepository: Repository<InterventionDetails>,
    @InjectRepository(Intervention)
    private readonly interventionRepository: Repository<Intervention>,
    
  ) {}

  async create(dto: CreateInterventionDetailsDto): Promise<InterventionDetails> {
    const { elemento, intervention_id } = dto;
    const intervention = await this.interventionRepository.findOne({
        where: { id_intervencion: intervention_id },
      });
    
    if (!intervention) {
    throw new NotFoundException(`No se encontró la intervención con ID "${intervention_id}"`);
    }
    // Verificar si ya existe un detalle con el mismo elemento en la misma intervención
    const existingDetail = await this.interventionDetailsRepository.findOne({
        where: { 
          elemento, 
          intervention: { id_intervencion: intervention_id },
        },
        relations: ['intervention'],
      });
  
    if (existingDetail) {
      throw new ConflictException(`Ya existe un detalle con el elemento "${elemento}" en esta intervención`);
    }
  
    const newDetail = this.interventionDetailsRepository.create({
        ...dto,
        intervention, // Asignamos la intervención obtenida
      });
    return await this.interventionDetailsRepository.save(newDetail);
  }
  

  async findAll(): Promise<InterventionDetails[]> {
    return await this.interventionDetailsRepository.find({ relations: ['intervention'] });
  }

  async findOne(id: string): Promise<InterventionDetails> {
    const detail = await this.interventionDetailsRepository.findOne({ where: { id_intervention_details: id }, relations: ['intervention'] });
    if (!detail) {
      throw new NotFoundException(`Intervention Detail with ID ${id} not found`);
    }
    return detail;
  }

  async update(id: string, dto: Partial<CreateInterventionDetailsDto>): Promise<InterventionDetails> {
    const detail = await this.findOne(id);
    
    // Extraemos el elemento e intervention_id del DTO
    const { elemento, intervention_id } = dto;
  
    if (elemento && intervention_id) {
      // Verificar si ya existe otro detalle con el mismo elemento en la misma intervención
      const existingDetail = await this.interventionDetailsRepository.findOne({
        where: { 
          elemento, 
          intervention: { id_intervencion: intervention_id },
          id_intervention_details: Not(id) // Evita comparar el mismo registro
        },
        relations: ['intervention'],
      });
  
      if (existingDetail) {
        throw new ConflictException(`Ya existe un detalle con el elemento "${elemento}" en esta intervención`);
      }
    }
  
    Object.assign(detail, dto);
    return await this.interventionDetailsRepository.save(detail);
  }
  
  async remove(id: string): Promise<void> {
    const result = await this.interventionDetailsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Intervention Detail with ID ${id} not found`);
    }
  }
}
