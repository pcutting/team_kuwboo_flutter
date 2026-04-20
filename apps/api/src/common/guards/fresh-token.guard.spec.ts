import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';
import {
  FRESH_TOKEN_MAX_AGE_SECONDS,
  FreshTokenGuard,
  STALE_TOKEN_ERROR_CODE,
} from './fresh-token.guard';

function ctxWithHeader(authorization: string | undefined): ExecutionContext {
  const req = { headers: authorization ? { authorization } : {} };
  return {
    switchToHttp: () => ({ getRequest: () => req }),
  } as unknown as ExecutionContext;
}

/**
 * Lowest-level JWT shape we need — sign raw claims including a custom
 * `iat`. jsonwebtoken strips `iat` from the payload and injects its
 * own unless we pass the claim at sign time via options, so we go
 * through `jwt.sign(Buffer, secret)` which treats the payload as
 * pre-encoded JSON. That preserves every claim verbatim.
 */
function sign(payload: Record<string, unknown>): string {
  return jwt.sign(
    Buffer.from(JSON.stringify(payload)),
    'test-secret',
    { algorithm: 'HS256' },
  );
}

/** Build a token with no iat claim at all. */
function signNoIat(payload: Record<string, unknown>): string {
  return jwt.sign(
    Buffer.from(JSON.stringify(payload)),
    'test-secret',
    { algorithm: 'HS256' },
  );
}

describe('FreshTokenGuard', () => {
  const guard = new FreshTokenGuard();

  it('rejects a request with no Authorization header', () => {
    try {
      guard.canActivate(ctxWithHeader(undefined));
      fail('expected UnauthorizedException');
    } catch (e) {
      expect(e).toBeInstanceOf(UnauthorizedException);
      expect((e as UnauthorizedException).getResponse()).toMatchObject({
        code: STALE_TOKEN_ERROR_CODE,
      });
    }
  });

  it('rejects a malformed Authorization header', () => {
    expect(() => guard.canActivate(ctxWithHeader('notabearer'))).toThrow(
      UnauthorizedException,
    );
  });

  it('rejects a token with no iat claim', () => {
    const token = signNoIat({ sub: 'u' });
    expect(() =>
      guard.canActivate(ctxWithHeader(`Bearer ${token}`)),
    ).toThrow(UnauthorizedException);
  });

  it('rejects a token whose iat is older than 15 minutes', () => {
    const staleIat = Math.floor(Date.now() / 1000) - (16 * 60);
    const token = sign({ sub: 'u', iat: staleIat });
    expect(() =>
      guard.canActivate(ctxWithHeader(`Bearer ${token}`)),
    ).toThrow(UnauthorizedException);
  });

  it('accepts a token whose iat is within 15 minutes', () => {
    const iat = Math.floor(Date.now() / 1000) - 60;
    const token = sign({ sub: 'u', iat });
    expect(guard.canActivate(ctxWithHeader(`Bearer ${token}`))).toBe(true);
  });

  it('uses a 15-minute threshold', () => {
    expect(FRESH_TOKEN_MAX_AGE_SECONDS).toBe(15 * 60);
  });
});
