import { IsOptional, IsUUID, IsString, IsNumberString } from 'class-validator';

export class AdminAuditQueryDto {
  @IsOptional()
  @IsNumberString()
  page?: string;

  @IsOptional()
  @IsNumberString()
  limit?: string;

  @IsOptional()
  @IsUUID()
  adminUserId?: string;

  @IsOptional()
  @IsString()
  actionType?: string;

  @IsOptional()
  @IsString()
  targetType?: string;
}
