import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { DatingAgeGuard } from './dating-age.guard';
import { AgeVerificationStatus } from '../enums';

function ctxFor(user: unknown): ExecutionContext {
  return {
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  } as unknown as ExecutionContext;
}

describe('DatingAgeGuard', () => {
  const guard = new DatingAgeGuard();

  it('allows when no user is attached (delegates 401 to auth layer)', () => {
    expect(guard.canActivate(ctxFor(undefined))).toBe(true);
  });

  it('rejects with dob_required when DOB missing', () => {
    try {
      guard.canActivate(
        ctxFor({ id: 'u', dateOfBirth: null, ageVerificationStatus: 'self_declared' }),
      );
      fail('expected throw');
    } catch (e) {
      expect(e).toBeInstanceOf(ForbiddenException);
      expect((e as ForbiddenException).getResponse()).toMatchObject({
        code: 'dob_required',
      });
    }
  });

  it('rejects with under_18 when age below threshold', () => {
    const dob = new Date();
    dob.setFullYear(dob.getFullYear() - 17);
    try {
      guard.canActivate(
        ctxFor({ id: 'u', dateOfBirth: dob, ageVerificationStatus: 'self_declared' }),
      );
      fail('expected throw');
    } catch (e) {
      expect((e as ForbiddenException).getResponse()).toMatchObject({
        code: 'under_18',
      });
    }
  });

  it('rejects with age_failed when provider verification failed', () => {
    const dob = new Date();
    dob.setFullYear(dob.getFullYear() - 30);
    try {
      guard.canActivate(
        ctxFor({
          id: 'u',
          dateOfBirth: dob,
          ageVerificationStatus: AgeVerificationStatus.FAILED,
        }),
      );
      fail('expected throw');
    } catch (e) {
      expect((e as ForbiddenException).getResponse()).toMatchObject({
        code: 'age_failed',
      });
    }
  });

  it('allows 18+ with valid DOB', () => {
    const dob = new Date();
    dob.setFullYear(dob.getFullYear() - 21);
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

  describe('ageFromDob', () => {
    it('accounts for birthday not yet reached this year', () => {
      const now = new Date('2026-01-01');
      // Born Dec 2000 → on Jan 2026 = 25 (birthday was last month)
      const dob = new Date('2000-12-15');
      expect(DatingAgeGuard.ageFromDob(dob, now)).toBe(25);

      // Born Feb 2005 → on Jan 2026 = 20 (not yet 21)
      const dob2 = new Date('2005-02-15');
      expect(DatingAgeGuard.ageFromDob(dob2, now)).toBe(20);
    });
  });
});
