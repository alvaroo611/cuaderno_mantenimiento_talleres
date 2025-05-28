import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Vehicle } from './entities/vehicle.entity';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { Client } from 'src/client/entities/client.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';
import { InterventionDetails } from 'src/intervention_details/entities/intervention_details.entity';



@Injectable()
export class VehicleService {
  constructor(
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: Repository<Vehicle>,
    @InjectRepository(Client)
    private readonly clientRepository: Repository<Client>,
     @InjectRepository(Intervention)
    private readonly interventionRepository: Repository<Intervention>,
     @InjectRepository(InterventionDetails)
    private readonly interventionDetailsRepository: Repository<InterventionDetails>,
    
  ) {}

  async create(createVehicleDto: CreateVehicleDto) {
    const { bastidor, matricula,client_id } = createVehicleDto;

    const existingVehicle = await this.vehicleRepository.findOne({
      where: [{ bastidor }, { matricula }],
    });

    if (existingVehicle) {
      throw new ConflictException('Vehicle with this VIN or license plate already exists.');
    }
    
    const client = await this.clientRepository.findOne({ where: { id_client: client_id } });

    if (!client) {
      throw new NotFoundException('Client not found.');
    }
  
    // Crear el vehículo y asociarlo con el cliente
    const vehicle = this.vehicleRepository.create({
      ...createVehicleDto,
      client, // Asocia el cliente al vehículo
    });
    await this.vehicleRepository.save(vehicle);
    return {message:'Vehicle created sucefully.'}
  }

  async findAll(): Promise<Vehicle[]> {
    return await this.vehicleRepository.find({ relations: ['client'] });
  }

  async findOne(id_vehicle: string) {
    const vehicle= await this.vehicleRepository.findOne({
      where: { id_vehicle }, 
      relations: ['client']
    }); 
    if (!vehicle) {
        throw new NotFoundException('Vehicle not found.');
    }

    return vehicle;
  }
  
 async findByClientId(clientId: string): Promise<Vehicle[]> {
  console.log('[findByClientId] 🔍 Buscando vehículos para clientId:', clientId);

  const vehicles = await this.vehicleRepository.find({
    where: {
      client: {
        id_client: clientId,
      },
    },
    relations: ['client'],
  });

  console.log('[findByClientId] 📦 Resultado de la búsqueda:', vehicles);

  if (vehicles.length === 0) {
    console.log('[findByClientId] ⚠️ No se encontraron vehículos para este cliente.');
    throw new NotFoundException('No vehicles found for this client.');
  }

  console.log('[findByClientId] ✅ Vehículos encontrados:', vehicles.length);
  return vehicles;
}


  async update(id_vehicle: string, updateVehicleDto: UpdateVehicleDto) {
    const existingVehicle = await this.vehicleRepository.findOne({
        where: [
          { matricula: updateVehicleDto.matricula },
          { bastidor: updateVehicleDto.bastidor }
        ],
      });

    if (existingVehicle && existingVehicle.id_vehicle !== id_vehicle) {
    throw new BadRequestException('License plate or chassis number is already in use.');
    }
    const vehicle = await this.vehicleRepository.preload({
      id_vehicle,
      ...updateVehicleDto,
    });


    if (!vehicle) {
      throw new NotFoundException('Vehicle not found.');
    }
    await this.vehicleRepository.save(vehicle);
    return {message:'Vehicle updated sucefully.'}
  }

  async remove(id_vehicle: string): Promise<void> {
    // 1. Obtener intervenciones del vehículo
    const interventions = await this.interventionRepository.find({
      where: { vehicle: { id_vehicle } }
    });

    // 2. Por cada intervención, borrar sus detalles
    for (const intervention of interventions) {
      await this.interventionDetailsRepository.delete({ intervention: { id_intervencion: intervention.id_intervencion } });
    }

    // 3. Borrar intervenciones
    await this.interventionRepository.delete({ vehicle: { id_vehicle } });

    // 4. Borrar vehículo
    const result = await this.vehicleRepository.delete(id_vehicle);

    if (result.affected === 0) {
      throw new NotFoundException('Vehicle not found.');
    }
  }


}
