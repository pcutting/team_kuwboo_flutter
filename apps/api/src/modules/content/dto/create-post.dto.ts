import { IsString, IsOptional, IsEnum, IsBoolean, MaxLength, IsNumber, Min, Max } from 'class-validator';
import { Visibility, PostSubType } from '../../../common/enums';

export class CreatePostDto {
  @IsString()
  @MaxLength(10000)
  text!: string;

  @IsOptional()
  @IsEnum(PostSubType)
  subType?: PostSubType;

  @IsOptional()
  @IsBoolean()
  isPinned?: boolean;

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
