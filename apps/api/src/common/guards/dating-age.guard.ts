import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { AgeVerificationStatus } from '../enums';

/**
 * Hard 18+ gate required on every dating-module route by
 * IDENTITY_CONTRACT §6 (dating is the only hard gate in the product;
 * everything else degrades gracefully to a soft nudge).
 *
 * Contract-specified error codes:
 *   - `dob_required`  → user has not set a birthday
 *   - `under_18`      → age_from_dob < 18
 *   - `age_failed`    → provider verification came back negative
 *
 * Expects the JwtAuthGuard (or equivalent) to have populated `req.user`
 * with `{ id, dateOfBirth, ageVerificationStatus }`. If the request
 * carries no authenticated user at all, this guard lets the 401 surface
 * from the auth layer rather than masking it as 403.
 */
@Injectable()
export class DatingAgeGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    const user = req.user;
    if (!user) return true;

    if (user.ageVerificationStatus === AgeVerificationStatus.FAILED) {
      throw new ForbiddenException({ code: 'age_failed' });
    }

    const dob = user.dateOfBirth;
    if (!dob) {
      throw new ForbiddenException({ code: 'dob_required' });
    }

    const age = DatingAgeGuard.ageFromDob(dob instanceof Date ? dob : new Date(dob));
    if (age < 18) {
      throw new ForbiddenException({ code: 'under_18' });
    }
    return true;
  }

  /** Exposed for unit tests. */
  static ageFromDob(dob: Date, now: Date = new Date()): number {
    let age = now.getFullYear() - dob.getFullYear();
    const m = now.getMonth() - dob.getMonth();
    if (m < 0 || (m === 0 && now.getDate() < dob.getDate())) age--;
    return age;
  }
}
