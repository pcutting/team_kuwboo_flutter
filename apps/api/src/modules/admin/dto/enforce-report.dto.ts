import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum EnforceAction {
  REMOVE_CONTENT = 'remove_content',
  WARN_USER = 'warn_user',
  SUSPEND_USER = 'suspend_user',
  DISMISS = 'dismiss',
}

export class EnforceReportDto {
  @IsEnum(EnforceAction)
  action!: EnforceAction;

  @IsOptional()
  @IsString()
  reason?: string;
}
