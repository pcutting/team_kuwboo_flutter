import {
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsBoolean,
  MaxLength,
  Min,
} from 'class-validator';
import { ProductCondition, Visibility } from '../../../common/enums';

export class CreateProductDto {
  @IsString()
  @MaxLength(255)
  title!: string;

  @IsString()
  description!: string;

  @IsNumber()
  @Min(0)
  priceCents!: number;

  @IsOptional()
  @IsString()
  @MaxLength(3)
  currency?: string;

  @IsEnum(ProductCondition)
  condition!: ProductCondition;

  @IsOptional()
  @IsBoolean()
  isDeal?: boolean;

  @IsOptional()
  @IsNumber()
  @Min(0)
  originalPriceCents?: number;

  @IsOptional()
  @IsEnum(Visibility)
  visibility?: Visibility;

  @IsOptional()
  @IsNumber()
  @Min(-90)
  latitude?: number;

  @IsOptional()
  @IsNumber()
  @Min(-180)
  longitude?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  locationName?: string;

  @IsOptional()
  @IsString({ each: true })
  tags?: string[];
}
