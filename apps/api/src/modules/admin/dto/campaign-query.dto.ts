import { IsOptional, IsString } from 'class-validator';

export class CampaignQueryDto {
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
