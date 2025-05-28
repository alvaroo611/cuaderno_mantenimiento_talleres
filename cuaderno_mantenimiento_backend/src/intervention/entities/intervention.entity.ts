// src/entities/intervention.entity.ts
import { InterventionDetails } from 'src/intervention_details/entities/intervention_details.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
 // Importa la entidad Vehicle

@Entity()
export class Intervention {
  @PrimaryGeneratedColumn('uuid')
  id_intervencion: string;

  @Column({ type: 'date' })
  fecha: string;

  @Column()
  kilometraje: number;

  @Column()
  tipo_intervencion: string;

  @Column({ nullable: true })
  observaciones: string;
  @OneToMany(() => InterventionDetails, (details) => details.intervention)
  details: InterventionDetails[];
  // Relación ManyToOne con Vehicle
  @ManyToOne(() => Vehicle, (vehicle) => vehicle.interventions)
  @JoinColumn({ name: 'vehicle_id' })
  vehicle: Vehicle;
}
