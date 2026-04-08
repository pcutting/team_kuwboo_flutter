import { IsString, IsUUID, IsOptional, IsNumber, IsEnum, MaxLength, Min, Max } from 'class-validator';
import { Visibility } from '../../../common/enums';

export class CreateVideoDto {
  @IsString()
  @MaxLength(1024)
  videoUrl!: string;

  @IsString()
  @MaxLength(1024)
  thumbnailUrl!: string;

  @IsNumber()
  @Min(1)
  @Max(300)
  durationSeconds!: number;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  caption?: string;

  @IsOptional()
  @IsUUID()
  musicId?: string;

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
