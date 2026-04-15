import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { DatingAgeGuard } from '../../common/guards/dating-age.guard';
import { AgeVerificationStatus } from '../../common/enums';

/**
 * These tests exercise the DatingAgeGuard as wired at the class level on
 * DatingController. The guard is the only thing that gates access to the
 * dating route surface, so we verify its boundary behavior holds when
 * instantiated in the controller's context.
 */
function ctxFor(user: unknown): ExecutionContext {
  return {
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
    getHandler: () => undefined,
    getClass: () => undefined,
  } as unknown as ExecutionContext;
}

describe('DatingController (DatingAgeGuard wiring)', () => {
  const guard = new DatingAgeGuard();

  it('rejects with dob_required when dateOfBirth is null', () => {
    try {
      guard.canActivate(
        ctxFor({
          id: 'u',
          dateOfBirth: null,
          ageVerificationStatus: AgeVerificationStatus.SELF_DECLARED,
        }),
      );
      fail('expected ForbiddenException');
    } catch (e) {
      expect(e).toBeInstanceOf(ForbiddenException);
      expect((e as ForbiddenException).getResponse()).toMatchObject({
        code: 'dob_required',
      });
    }
  });

  it('rejects an exactly-17-year-old with under_18', () => {
    const dob = new Date();
    dob.setFullYear(dob.getFullYear() - 17);
    try {
      guard.canActivate(
        ctxFor({
          id: 'u',
          dateOfBirth: dob,
          ageVerificationStatus: AgeVerificationStatus.SELF_DECLARED,
        }),
      );
      fail('expected ForbiddenException');
    } catch (e) {
      expect(e).toBeInstanceOf(ForbiddenException);
      expect((e as ForbiddenException).getResponse()).toMatchObject({
        code: 'under_18',
      });
    }
  });

  it('accepts an exactly-18-year-old (boundary)', () => {
    // Build a DOB of exactly 18 years ago (same Y/M/D).
    const now = new Date();
    const dob = new Date(
      now.getFullYear() - 18,
      now.getMonth(),
      now.getDate(),
    );
    expect(
      guard.canActivate(
        ctxFor({
          id: 'u',
          dateOfBirth: dob,
          ageVerificationStatus: AgeVerificationStatus.SELF_DECLARED,
        }),
      ),
    ).toBe(true);
  });
});
