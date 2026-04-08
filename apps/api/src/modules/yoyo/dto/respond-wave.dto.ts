import { IsBoolean } from 'class-validator';

export class RespondWaveDto {
  @IsBoolean()
  accept!: boolean;
}
