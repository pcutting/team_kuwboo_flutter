import { IsOptional, IsBoolean, IsInt, IsString, Min, Max, MaxLength } from 'class-validator';

export class UpdateYoyoSettingsDto {
  @IsOptional()
  @IsBoolean()
  isVisible?: boolean;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(500)
  radiusKm?: number;

  @IsOptional()
  @IsInt()
  @Min(13)
  @Max(120)
  ageMin?: number;

  @IsOptional()
  @IsInt()
  @Min(13)
  @Max(120)
  ageMax?: number;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  genderFilter?: string;
}
