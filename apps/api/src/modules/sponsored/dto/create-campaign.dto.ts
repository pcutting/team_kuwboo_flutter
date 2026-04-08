import { IsUUID, IsNumber, IsDateString, IsOptional, IsObject, Min } from 'class-validator';

export class CreateCampaignDto {
  @IsUUID()
  contentId!: string;

  @IsNumber()
  @Min(100)
  budgetCents!: number;

  @IsOptional()
  @IsObject()
  targeting?: Record<string, any>;

  @IsDateString()
  startsAt!: string;

  @IsDateString()
  endsAt!: string;
}
