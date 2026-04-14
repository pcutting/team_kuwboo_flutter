import { IsArray, IsUUID, ArrayMaxSize } from 'class-validator';

export class SetInterestTagsDto {
  @IsArray()
  @ArrayMaxSize(20)
  @IsUUID('4', { each: true })
  interest_ids!: string[];
}
