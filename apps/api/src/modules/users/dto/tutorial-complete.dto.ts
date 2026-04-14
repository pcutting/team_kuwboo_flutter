import { IsInt, Min } from 'class-validator';

export class TutorialCompleteDto {
  @IsInt()
  @Min(0)
  version!: number;
}
