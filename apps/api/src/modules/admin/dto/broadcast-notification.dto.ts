import { IsString, IsOptional, MaxLength } from 'class-validator';

export class BroadcastNotificationDto {
  @IsString()
  title!: string;

  @IsString()
  @MaxLength(1000)
  message!: string;

  @IsOptional()
  @IsString()
  targetRole?: string;
}
