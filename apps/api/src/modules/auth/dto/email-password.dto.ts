import {
  IsEmail,
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  Length,
  MaxLength,
  MinLength,
} from 'class-validator';
import { DobChoice } from '../../../common/enums';

export class EmailRegisterDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  /**
   * ISO-8601 date (`YYYY-MM-DD` or full timestamp). When supplied the
   * user's `dobChoice` is forced to `PROVIDED` and `ageVerificationStatus`
   * is upgraded to `SELF_DECLARED`.
   */
  @IsOptional()
  @IsISO8601()
  dateOfBirth?: string;

  @IsOptional()
  @IsEnum(DobChoice)
  dobChoice?: DobChoice;
}

export class EmailLoginDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(128)
  password!: string;
}

export class EmailForgotPasswordDto {
  @IsEmail()
  email!: string;
}

export class EmailResetPasswordDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(4, 12)
  code!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  newPassword!: string;
}

export class EmailVerifyConfirmDto {
  @IsString()
  @Length(4, 12)
  code!: string;
}
