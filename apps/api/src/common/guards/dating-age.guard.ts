import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { AgeVerificationStatus, DobChoice } from '../enums';

/**
 * Hard 18+ gate required on every dating-module route by
 * IDENTITY_CONTRACT §6 (dating is the only hard gate in the product;
 * everything else degrades gracefully to a soft nudge).
 *
 * Contract-specified error codes (all returned with HTTP 403):
 *   - `dob_required`                → user has not set a birthday AND
 *                                      has no `dob_choice` yet (or
 *                                      their choice is `pending` /
 *                                      `skipped`). The mobile client
 *                                      routes to the DOB step.
 *   - `dob_privacy_declined`        → user selected
 *                                      `prefer_not_to_say`. Dating is
 *                                      permanently unavailable without
 *                                      a choice change, but feed /
 *                                      marketplace still work.
 *   - `dob_adult_self_declared_only` → user confirmed 18+ without
 *                                      giving an exact DOB
 *                                      (`adult_self_declared`). The
 *                                      discover feed allows this tier
 *                                      but richer dating features
 *                                      (matching, likes) may not; the
 *                                      current endpoint classifies the
 *                                      state so the caller can decide.
 *   - `under_18`                    → `dob_choice = provided` and
 *                                      age_from_dob < 18.
 *   - `age_failed`                  → provider verification came back
 *                                      negative.
 *
 * Expects the JwtAuthGuard (or equivalent) to have populated `req.user`
 * with `{ id, dateOfBirth, ageVerificationStatus, dobChoice }`. If the
 * request carries no authenticated user at all, this guard lets the
 * 401 surface from the auth layer rather than masking it as 403.
 *
 * Per the spec for this endpoint (pure discover): users in the
 * `adult_self_declared` tier are ALLOWED through. The
 * `dob_adult_self_declared_only` code is reserved for future richer
 * dating routes (matches, likes) that may wish to gate harder.
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

    const choice: DobChoice | undefined = user.dobChoice;

    if (choice === DobChoice.PREFER_NOT_TO_SAY) {
      throw new ForbiddenException({ code: 'dob_privacy_declined' });
    }

    const dob = user.dateOfBirth;

    // No exact DOB on file. Split the error by the onboarding choice so
    // the client can route precisely.
    if (!dob) {
      if (choice === DobChoice.ADULT_SELF_DECLARED) {
        // Adult-self-declared tier: allow pure discover. Richer dating
        // routes can opt into a stricter guard that emits
        // `dob_adult_self_declared_only` instead.
        return true;
      }
      // PENDING / SKIPPED / undefined / PROVIDED-but-no-dob all funnel
      // here. The DOB is required — route the client to the DOB step.
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
