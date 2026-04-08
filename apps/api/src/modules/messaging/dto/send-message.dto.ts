import { IsString, IsUUID, IsOptional, MaxLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  @MaxLength(5000)
  text!: string;

  @IsOptional()
  @IsUUID()
  mediaId?: string;
}
