import 'dotenv/config'; // Carga las variables de entorno desde el archivo .env
import * as joi from 'joi'; // Importa Joi para la validación

// Interfaz que define el tipo de las variables de entorno
interface EnvVars {
  DB_PORT: number;
  DB_HOST: string;
}

// Definición del esquema de validación usando Joi
const envsSchema = joi.object({
  DB_PORT: joi.number().required(),
  DB_HOST: joi.string().required(),
  
}).unknown(true); // Permitir variables de entorno adicionales no especificadas en el esquema

// Validación de las variables de entorno
const { error, value } = envsSchema.validate(process.env);

if (error) {
  throw new Error(`Config validation error: ${error.message}`); // Lanza un error si la validación falla
}

// Asigna las variables validadas a un objeto con la interfaz correspondiente
const envVars: EnvVars = value;

export const envs = {
  port: envVars.DB_PORT,
  host: envVars.DB_HOST,
 
};
