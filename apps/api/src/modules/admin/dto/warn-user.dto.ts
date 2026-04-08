import { IsString, MaxLength } from 'class-validator';

export class WarnUserDto {
  @IsString()
  @MaxLength(1000)
  message!: string;
}
