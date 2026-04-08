import { IsUUID, IsEnum } from 'class-validator';
import { YoyoOverrideAction } from '../../../common/enums';

export class CreateOverrideDto {
  @IsUUID()
  targetUserId!: string;

  @IsEnum(YoyoOverrideAction)
  action!: YoyoOverrideAction;
}
