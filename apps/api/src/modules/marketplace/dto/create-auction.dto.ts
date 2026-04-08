import { IsUUID, IsNumber, IsDateString, IsOptional, Min } from 'class-validator';

export class CreateAuctionDto {
  @IsUUID()
  productId!: string;

  @IsNumber()
  @Min(1)
  startPriceCents!: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  minIncrementCents?: number;

  @IsDateString()
  startsAt!: string;

  @IsDateString()
  endsAt!: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  antiSnipeMinutes?: number;
}
