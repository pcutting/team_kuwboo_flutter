import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import * as jwt from 'jsonwebtoken';

/**
 * Age threshold for a JWT to be considered "fresh" for destructive
 * account-level operations (account delete / purge). 15 minutes is the
 * same window Apple's Sign-in with Apple and most banking apps use for
 * re-auth before a privileged action.
 *
 * Kept as an exported constant so tests and the guard itself agree on
 * the boundary without drifting.
 */
export const FRESH_TOKEN_MAX_AGE_SECONDS = 15 * 60;

/**
 * Error code returned in the 401 body when the access token is past the
 * freshness threshold. The mobile client should route this to a
 * "re-authenticate to confirm" screen — PIN prompt for phone/email
 * users, re-SSO for Google/Apple users.
 */
export const STALE_TOKEN_ERROR_CODE = 'stale_token';

/**
 * Guards destructive account endpoints (DELETE /users/me, POST
 * /users/me/purge) by rejecting any request whose JWT was issued more
 * than `FRESH_TOKEN_MAX_AGE_SECONDS` ago.
 *
 * This runs AFTER the `JwtAuthGuard` in the APP_GUARD chain — so by the
 * time `canActivate` fires we already know the token is validly signed
 * and not expired in the absolute sense (per `jwt.accessExpiry`). The
 * only thing left to check is the `iat` claim against wall-clock now.
 *
 * We re-decode the token (no signature verification — the global JWT
 * guard already did that) rather than plumbing `iat` through
 * `JwtStrategy.validate()`. Keeping the freshness check local to this
 * guard means the strategy's return shape — which many downstream
 * guards read — stays untouched.
 *
 * NOTE: this is not a replacement for a proper confirm-identity
 * endpoint; it's a "recent-enough login" shortcut that keeps M3
 * shippable. The proper re-auth flow is tracked for the next milestone.
 */
@Injectable()
export class FreshTokenGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<Request>();

    const authHeader = req.headers?.authorization;
    if (!authHeader || typeof authHeader !== 'string') {
      // Let the upstream JwtAuthGuard produce the canonical 401. If we
      // are ever wired in without the JWT guard somehow, the safest
      // thing is to still reject.
      throw new UnauthorizedException({
        code: STALE_TOKEN_ERROR_CODE,
        message: 'Re-authenticate to confirm account deletion',
      });
    }

    const [scheme, token] = authHeader.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException({
        code: STALE_TOKEN_ERROR_CODE,
        message: 'Re-authenticate to confirm account deletion',
      });
    }

    let payload: { iat?: number } | null;
    try {
      payload = jwt.decode(token) as { iat?: number } | null;
    } catch {
      payload = null;
    }

    if (!payload || typeof payload.iat !== 'number') {
      throw new UnauthorizedException({
        code: STALE_TOKEN_ERROR_CODE,
        message: 'Re-authenticate to confirm account deletion',
      });
    }

    const nowSeconds = Math.floor(Date.now() / 1000);
    if (nowSeconds - payload.iat > FRESH_TOKEN_MAX_AGE_SECONDS) {
      throw new UnauthorizedException({
        code: STALE_TOKEN_ERROR_CODE,
        message: 'Re-authenticate to confirm account deletion',
      });
    }

    return true;
  }
}
