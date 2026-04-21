import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { CredentialType, Role } from '../../common/enums';
import { FRESH_TOKEN_MAX_AGE_SECONDS } from '../../common/guards/fresh-token.guard';

/**
 * Unit coverage for `AuthService.confirmIdentity()` — the SSO re-prove
 * entry point used when a Google/Apple-only user hits a `stale_token`
 * 401 on a privileged endpoint (e.g. `DELETE /users/me`) and needs a
 * fresh JWT without the password path available.
 *
 * The service collaborators (`credentialsService`, `verificationService`,
 * `usersService`, `sessionsService`, ...) are all stubbed. We only care
 * about the two real collaborators this method uses —
 * `credentialsService.findByIdentity` and
 * `verificationService.verifyEmailOtp` — plus the real `JwtService` so
 * the emitted token is a genuine signed JWT we can inspect.
 */
describe('AuthService.confirmIdentity', () => {
  const accessSecret = 'test-access-secret';
  const jwtService = new JwtService({ secret: accessSecret });

  const fakeConfig: Partial<ConfigService> = {
    get: (key: string) => (key === 'jwt.accessSecret' ? accessSecret : undefined),
  };

  function makeService(overrides: {
    findByIdentity: jest.Mock;
    verifyEmailOtp: jest.Mock;
  }): AuthService {
    const credentialsService = { findByIdentity: overrides.findByIdentity };
    const verificationService = { verifyEmailOtp: overrides.verifyEmailOtp };

    // The stubs that confirmIdentity() never touches — cast to `any`
    // because we deliberately don't implement them.
    return new AuthService(
      fakeConfig as ConfigService,
      jwtService,
      {} as any,
      {} as any,
      verificationService as any,
      {} as any,
      credentialsService as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
    );
  }

  const fakeUser = {
    id: '00000000-0000-0000-0000-0000000000aa',
    role: Role.USER,
  };

  it('returns an elevated token + ISO expiresAt on a valid OTP', async () => {
    const findByIdentity = jest.fn().mockResolvedValue({
      id: 'cred-1',
      user: fakeUser,
    });
    const verifyEmailOtp = jest.fn().mockResolvedValue(true);
    const svc = makeService({ findByIdentity, verifyEmailOtp });

    const before = Math.floor(Date.now() / 1000);
    const res = await svc.confirmIdentity('user@example.com', '424242');
    const after = Math.floor(Date.now() / 1000);

    expect(findByIdentity).toHaveBeenCalledWith(
      CredentialType.EMAIL,
      'user@example.com',
    );
    expect(verifyEmailOtp).toHaveBeenCalledWith('user@example.com', '424242');
    expect(typeof res.elevatedToken).toBe('string');

    const decoded = jwtService.verify<{
      sub: string;
      role: string;
      iat: number;
      exp: number;
      jti: string;
    }>(res.elevatedToken, { secret: accessSecret });

    expect(decoded.sub).toBe(fakeUser.id);
    expect(decoded.role).toBe(Role.USER);
    expect(decoded.jti).toEqual(expect.any(String));
    // `iat` should be roughly now, and `exp` should be 15 minutes out.
    expect(decoded.iat).toBeGreaterThanOrEqual(before);
    expect(decoded.iat).toBeLessThanOrEqual(after + 1);
    expect(decoded.exp - decoded.iat).toBe(FRESH_TOKEN_MAX_AGE_SECONDS);

    // The response's `expiresAt` must match the JWT `exp` claim.
    expect(new Date(res.expiresAt).getTime()).toBe(decoded.exp * 1000);
  });

  it('throws 401 invalid_otp when the email is unknown (no EMAIL credential)', async () => {
    const findByIdentity = jest.fn().mockResolvedValue(null);
    const verifyEmailOtp = jest.fn();
    const svc = makeService({ findByIdentity, verifyEmailOtp });

    await expect(
      svc.confirmIdentity('ghost@example.com', '111111'),
    ).rejects.toBeInstanceOf(UnauthorizedException);

    // Anti-enumeration: don't even attempt the OTP lookup when the
    // email is unknown — saves DB work and keeps timing bounded.
    expect(verifyEmailOtp).not.toHaveBeenCalled();
  });

  it('throws 401 invalid_otp on an expired / missing verification row', async () => {
    const findByIdentity = jest
      .fn()
      .mockResolvedValue({ id: 'cred-1', user: fakeUser });
    // Mirror what `VerificationService.verifyEmailOtp` does for a
    // missing / expired row: 400 invalid_otp. confirmIdentity must
    // collapse it to a 401 so the response shape is uniform.
    const verifyEmailOtp = jest.fn().mockImplementation(async () => {
      const err: any = new Error('No pending verification found');
      err.response = { code: 'invalid_otp' };
      throw err;
    });
    const svc = makeService({ findByIdentity, verifyEmailOtp });

    await expect(
      svc.confirmIdentity('user@example.com', '999999'),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('throws 401 invalid_otp on a wrong code (verifyEmailOtp rejects)', async () => {
    const findByIdentity = jest
      .fn()
      .mockResolvedValue({ id: 'cred-1', user: fakeUser });
    const verifyEmailOtp = jest
      .fn()
      .mockRejectedValue(new UnauthorizedException('Invalid code'));
    const svc = makeService({ findByIdentity, verifyEmailOtp });

    const err = await svc
      .confirmIdentity('user@example.com', '000000')
      .catch((e) => e);

    expect(err).toBeInstanceOf(UnauthorizedException);
    // Contract: error body carries the uniform invalid_otp code
    // regardless of whether the underlying cause was missing row,
    // wrong code, or rate-limited attempts.
    const body = err.getResponse();
    expect(body.code).toBe('invalid_otp');
  });

  it('normalises the email before lookup + OTP check (gmail dot-stripping)', async () => {
    const findByIdentity = jest
      .fn()
      .mockResolvedValue({ id: 'cred-1', user: fakeUser });
    const verifyEmailOtp = jest.fn().mockResolvedValue(true);
    const svc = makeService({ findByIdentity, verifyEmailOtp });

    await svc.confirmIdentity('A.L.I.C.E@GMail.COM', '424242');

    // Gmail normalisation strips dots in the local-part and lowercases
    // the whole address — the same rule `normaliseEmail()` applies on
    // the register / login paths. Both collaborators must see the
    // normalised form, otherwise a user who registered as
    // `alice@gmail.com` couldn't re-prove as `a.l.i.c.e@gmail.com`.
    expect(findByIdentity).toHaveBeenCalledWith(
      CredentialType.EMAIL,
      'alice@gmail.com',
    );
    expect(verifyEmailOtp).toHaveBeenCalledWith('alice@gmail.com', '424242');
  });
});
