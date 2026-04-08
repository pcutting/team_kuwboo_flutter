import { IsUUID, IsOptional, IsString, MaxLength } from 'class-validator';

export class SendWaveDto {
  @IsUUID()
  toUserId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  message?: string;
}
