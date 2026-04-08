import { IsOptional, IsString } from 'class-validator';

export class MarketplaceQueryDto {
  @IsOptional()
  @IsString()
  page?: string;

  @IsOptional()
  @IsString()
  limit?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
