import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { Person } from './person/entities/person.entity';
import { Client } from './client/entities/client.entity';
import { Vehicle } from './vehicle/entities/vehicle.entity';
import { Intervention } from './intervention/entities/intervention.entity';
import { InterventionDetails } from './intervention_details/entities/intervention_details.entity';
import { PersonModule } from './person/person.module';
import { ClientModule } from './client/client.module';
import { VehicleModule } from './vehicle/vehicle.module';
import { InterventionModule } from './intervention/intervention.module';
import { InterventionDetailsModule } from './intervention_details/intervention_details.module';
import { DashboardModule } from './dashboard/dashboard.module';





//Ejecutar docker  docker exec -it mysql_cuaderno_mantenimiento mysql -u root -p
@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST,  
      port: Number(process.env.DB_PORT) || 3306,
      username: process.env.MYSQL_USER,
      password: process.env.MYSQL_ROOT_PASSWORD,
      database: process.env.MYSQL_DATABASE ,
      autoLoadEntities: true,
      entities:[Person,Client,Vehicle,Intervention,InterventionDetails],
      synchronize: true,
    }),PersonModule, ClientModule,VehicleModule,InterventionModule,InterventionDetailsModule, DashboardModule
  ],
  controllers: [],
})
export class AppModule {}
