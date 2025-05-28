import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { DataSource } from 'typeorm';
import { ValidationPipe } from '@nestjs/common';
async function bootstrap() {
  dotenv.config();
  console.log('Environment Variables:', process.env);
  const app = await NestFactory.create(AppModule);
  app.enableCors(); // Permitir CORS para todas las peticiones
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Ignora campos no definidos en el DTO
      forbidNonWhitelisted: true, // Lanza error si hay campos desconocidos
      transform: true, // Convierte tipos de datos según el DTO
    }),
  );
  const dataSource = app.get(DataSource);
  async function testConnection() {
    try {
      await dataSource.query('SELECT 1');
      console.log('✅ Conexión a MySQL exitosa');
    } catch (error) {
      console.error('❌ Error de conexión a MySQL:', error);
    }
  }
  
  await testConnection();
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
