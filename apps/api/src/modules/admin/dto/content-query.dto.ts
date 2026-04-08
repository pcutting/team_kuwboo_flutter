import { IsOptional, IsEnum, IsUUID, IsNumberString } from 'class-validator';
import { ContentStatus, ContentType } from '../../../common/enums';

export class ContentQueryDto {
  @IsOptional()
  @IsNumberString()
  page?: string;

  @IsOptional()
  @IsNumberString()
  limit?: string;

  @IsOptional()
  @IsEnum(ContentStatus)
  status?: ContentStatus;

  @IsOptional()
  @IsEnum(ContentType)
  type?: ContentType;

  @IsOptional()
  @IsUUID()
  creatorId?: string;
}
