import { PartialType } from '@nestjs/mapped-types';
import { Person } from '../entities/person.entity';
import { CreatePersonDto } from './create-person.dto';


export class UpdatePersonDto extends PartialType(CreatePersonDto)
{
  
}