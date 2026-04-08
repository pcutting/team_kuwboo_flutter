import { IsEnum } from 'class-validator';
import { CampaignStatus } from '../../../common/enums';

export class UpdateCampaignStatusDto {
  @IsEnum(CampaignStatus)
  status!: CampaignStatus;
}
