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

  @IsOptional()
  @IsEnum(OnboardingProgress)
  onboardingProgress?: OnboardingProgress;
}
