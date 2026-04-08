import { IsEnum } from 'class-validator';
import { ContentStatus } from '../../../common/enums';

export class UpdateContentStatusDto {
  @IsEnum(ContentStatus)
  status!: ContentStatus;
}
