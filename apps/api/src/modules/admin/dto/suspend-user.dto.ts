import { IsString, IsOptional, IsInt, Min } from 'class-validator';

export class SuspendUserDto {
  @IsString()
  reason!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  durationDays?: number;
}
