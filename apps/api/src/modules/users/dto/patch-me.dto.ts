import {
  IsBoolean,
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  IsUrl,
  Length,
} from 'class-validator';
import { OnboardingProgress } from '../../../common/enums';
import { DobChoice } from '../../../common/enums/dob-choice.enum';

export class PatchMeDto {
  @IsOptional()
  @IsString()
  @Length(1, 100)
  displayName?: string;

  @IsOptional()
  @IsString()
  @Length(3, 30)
  username?: string;

  @IsOptional()
  @IsUrl()
  avatarUrl?: string;

  @IsOptional()
  @IsString()
  @Length(0, 500)
  bio?: string;

  /** ISO 8601 date (YYYY-MM-DD). `null` clears the field. */
  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;

  @IsOptional()
  @IsBoolean()
  birthdaySkipped?: boolean;

  /**
   * The user's explicit choice about sharing their DOB. Values carry
   * different implications for age-gated features and credibility —
   * see `users.service.ts#applyDobChoice` for the state transitions.
   */
  @IsOptional()
  @IsEnum(DobChoice)
  dobChoice?: DobChoice;

  @IsOptional()
  @IsEnum(OnboardingProgress)
  onboardingProgress?: OnboardingProgress;
}
