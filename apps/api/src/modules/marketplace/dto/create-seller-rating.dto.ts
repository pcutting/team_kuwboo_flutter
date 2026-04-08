import { IsUUID, IsNumber, IsString, IsOptional, Min, Max } from 'class-validator';

export class CreateSellerRatingDto {
  @IsUUID()
  productId!: string;

  @IsNumber()
  @Min(1)
  @Max(5)
  rating!: number;

  @IsOptional()
  @IsString()
  review?: string;
}
