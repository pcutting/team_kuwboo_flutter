import {
  IsString,
  IsOptional,
  IsDateString,
  IsInt,
  IsEnum,
  IsNumber,
  Min,
  Max,
  MaxLength,
} from 'class-validator';
import { Visibility } from '../../../common/enums';

export class CreateEventDto {
  @IsString()
  @MaxLength(255)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(5000)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  venue?: string;

  @IsDateString()
  startsAt!: string;

  @IsDateString()
  endsAt!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100000)
  capacity?: number;

  @IsOptional()
  @IsEnum(Visibility)
  visibility?: Visibility;

  @IsOptional()
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @IsOptional()
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  locationName?: string;

  @IsOptional()
  @IsString({ each: true })
  tags?: string[];
}
