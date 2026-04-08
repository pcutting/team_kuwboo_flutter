import { IsString } from 'class-validator';

export class UpdateProductStatusDto {
  @IsString()
  status!: string;
}
