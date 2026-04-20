import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

/**
 * Body for `DELETE /users/me` and `POST /users/me/purge`.
 *
 * For password-holding accounts the caller MUST include `password` —
 * the service re-checks it via bcrypt before touching any row. SSO-only
 * users (Google / Apple, no password set) may omit the field; for them
 * the `FreshTokenGuard` is the sole identity proof (JWT < 15min old).
 *
 * Length bounds mirror the registration DTO so callers can't ship a
 * 100KB string at us hoping bcrypt is slow enough to DoS the CPU.
 */
export class DeleteAccountDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  password?: string;
}
