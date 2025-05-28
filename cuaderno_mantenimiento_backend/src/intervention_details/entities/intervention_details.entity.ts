import { Intervention } from 'src/intervention/entities/intervention.entity';
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';


@Entity()
export class InterventionDetails {
  @PrimaryGeneratedColumn('uuid')
  id_intervention_details: string;

  @Column()
  elemento: string;

  @Column()
  estado: string;

  @Column({ nullable: true })
  marca: string;

  // Relación ManyToOne con Intervention
  @ManyToOne(() => Intervention, (intervention) => intervention.details)
  @JoinColumn({ name: 'intervention_id' })
  intervention: Intervention;
}
