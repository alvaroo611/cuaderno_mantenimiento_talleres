import { IsString, IsUUID, IsNotEmpty, IsArray, IsOptional, IsEmail, IsIn, Matches } from 'class-validator';
import { CreatePersonDto } from 'src/person/dto/create-person.dto'; // Asegúrate de que el DTO de Persona esté correctamente importado


export class CreateClientDto {
 @IsString()
  nombre: string;

  @IsEmail()
  correo: string;

  @IsString()
  password: string;



  @IsNotEmpty()
  @IsString()
  domicilio: string;

  @IsNotEmpty()
  @IsString()
  localidad: string;

  @IsNotEmpty()
  @IsString()
  provincia: string;

  @IsNotEmpty()
  @IsString()
  @Matches(/^\d{5}$/, { message: 'El código postal debe tener 5 dígitos.' })
  codigo_postal: string;
  

  @IsNotEmpty()
  @IsString()
  @Matches(/^\d{9}$/, { message: 'El teléfono debe tener 9 dígitos.' })
  telefono: string;
  

  
  
}
