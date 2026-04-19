import {
  Equals,
  IsBoolean,
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

  /**
   * Hard gate — the checkbox covering "I agree to the Terms and Privacy
   * Policy". The request is rejected at 400 if missing or false so no
   * user row is written without an accompanying consent audit entry.
   * The TERMS and PRIVACY consent rows (both at the current document
   * versions) are written atomically alongside the user in
   * `AuthService.emailRegister`.
   */
  @IsBoolean()
  @Equals(true, {
    message: 'You must agree to the Terms and Privacy Policy to register',
  })
  legalAccepted!: boolean;

  /**
   * Hard gate — the "I am 18 or older" self-attestation. Rejected at
   * 400 if missing or false. Deliberately NOT persisted as a
   * `UserConsent` row (this is an attestation, and the full DOB flow
   * already drives the `ageVerificationStatus` field); if a separate
   * audit of the tick-box is needed later, introduce an
   * `AGE_ATTESTATION` ConsentType.
   */
  @IsBoolean()
  @Equals(true, {
    message: 'You must confirm you are 18 or older',
  })
  ageConfirmed!: boolean;
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
