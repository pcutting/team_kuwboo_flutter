import { IsString } from 'class-validator';

export class UpdateCampaignStatusDto {
  @IsString()
  status!: string;
}
