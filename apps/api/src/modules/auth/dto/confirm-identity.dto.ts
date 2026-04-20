import { IsEmail, IsString, Length } from 'class-validator';

/**
 * Body for `POST /auth/confirm-identity`.
 *
 * Used by SSO-only users (no password hash) to re-prove ownership of the
 * account before privileged actions (e.g. account delete) when their
 * access token is past the 15-minute freshness window enforced by
 * `FreshTokenGuard`. The client first calls `POST /auth/email/send-otp`
 * to issue a fresh `EMAIL_VERIFY` code, then submits it here together
 * with the account email; a successful confirm returns a new short-lived
 * JWT that the caller substitutes into the `Authorization` header on
 * the privileged request.
 */
export class ConfirmIdentityDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(4, 12)
  otpCode!: string;
}
