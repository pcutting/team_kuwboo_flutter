import { IsUUID, IsEnum, IsOptional } from 'class-validator';
import { ThreadModuleKey } from '../../../common/enums';

export class CreateThreadDto {
  @IsUUID()
  recipientId!: string;

  @IsOptional()
  @IsEnum(ThreadModuleKey)
  moduleKey?: ThreadModuleKey;

  @IsOptional()
  @IsUUID()
  contextId?: string;
}
