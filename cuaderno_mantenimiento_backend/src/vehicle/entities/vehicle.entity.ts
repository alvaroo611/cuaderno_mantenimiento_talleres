// src/entities/vehicle.entity.ts
import { Client } from 'src/client/entities/client.entity';
import { Intervention } from 'src/intervention/entities/intervention.entity';

import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn } from 'typeorm';


@Entity()
export class Vehicle {
  @PrimaryGeneratedColumn('uuid')
  id_vehicle: string;

  @Column()
  marca: string;

  @Column()
  modelo: string;

  @Column()
  bastidor: string;

  @Column()
  tipo_motor: string;

  @Column()
  matricula: string;

  // Solo una próxima revisión
  @Column({ type: 'date', nullable: true })
  proxima_revision_fecha: string;

  @Column({ nullable: true })
  kilometraje_estimado_revision: number;

  
  @OneToMany(() => Intervention, (intervention) => intervention.vehicle)
  interventions: Intervention[];
  // Relación ManyToOne con Client
  @ManyToOne(() => Client, (client) => client.vehicles)
  @JoinColumn({ name: 'client_id' })
  client: Client;
    
}
