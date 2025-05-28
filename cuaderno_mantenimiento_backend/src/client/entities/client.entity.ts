// src/entities/client.entity.ts
import { Person } from 'src/person/entities/person.entity';
import { Vehicle } from 'src/vehicle/entities/vehicle.entity';
import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn, OneToMany } from 'typeorm';


@Entity()
export class Client {
  @PrimaryGeneratedColumn('uuid')
  id_client: string;


  @Column()
  domicilio: string;

  @Column()
  localidad: string;

  @Column()
  provincia: string;

  @Column()
  codigo_postal: string;

  @Column()
  telefono: string;
  
  @OneToOne(() => Person)
  @JoinColumn({ name: 'person_id' })  // Clave foránea para vincular con la tabla Person
  persona: Person;
  // Relación OneToMany con Vehicle
  @OneToMany(() => Vehicle, (vehicle) => vehicle.client)  // La relación inversa
  vehicles: Vehicle[];
}
