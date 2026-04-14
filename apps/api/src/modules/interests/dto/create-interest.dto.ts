import {
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateInterestDto {
  @IsString()
  @MaxLength(80)
  @Matches(/^[a-z0-9][a-z0-9-]*$/, {
    message: 'slug must be lowercase letters, digits, and hyphens',
  })
  slug!: string;

  @IsString()
  @MaxLength(120)
  label!: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  category?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  display_order?: number;
}
