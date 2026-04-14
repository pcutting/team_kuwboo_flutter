import { ArrayMaxSize, ArrayUnique, IsArray, IsUUID } from 'class-validator';

export class SelectInterestsDto {
  @IsArray()
  @ArrayMaxSize(100)
  @ArrayUnique()
  @IsUUID('4', { each: true })
  interest_ids!: string[];
}
