// src/entities/person.entity.ts
import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Person {
  @PrimaryGeneratedColumn('uuid')
  id_person: string;

  @Column()
  nombre: string;

  @Column({ unique: true })
  correo: string;

  @Column()
  password: string;

  @Column()
  rol: string;
  
}
