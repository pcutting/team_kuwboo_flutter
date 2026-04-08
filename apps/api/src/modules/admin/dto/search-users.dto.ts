import { IsString, IsOptional } from 'class-validator';

export class SearchUsersDto {
  @IsString()
  query!: string;

  @IsOptional()
  @IsString()
  page?: string;

  @IsOptional()
  @IsString()
  limit?: string;
}
