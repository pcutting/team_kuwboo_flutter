import { Injectable, Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import * as bcrypt from 'bcrypt';
import { Session } from './entities/session.entity';
import { User } from '../users/entities/user.entity';
import { RealtimeRevocationService } from '../realtime/realtime-revocation.service';

const REFRESH_TOKEN_EXPIRY_DAYS = 7;
const BCRYPT_ROUNDS = 10;

@Injectable()
export class SessionsService {
  private readonly logger = new Logger(SessionsService.name);

  constructor(
    private readonly em: EntityManager,
    private readonly realtimeRevocation: RealtimeRevocationService,
  ) {}

  async create(
    user: User,
    refreshToken: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<Session> {
    const refreshTokenHash = await bcrypt.hash(refreshToken, BCRYPT_ROUNDS);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);

    const session = this.em.create(Session, {
      user,
      refreshTokenHash,
      userAgent: meta?.userAgent,
      ipAddress: meta?.ipAddress,
      expiresAt,
    } as any);

    await this.em.flush();
    return session;
  }

  async findValidSession(userId: string): Promise<Session | null> {
    return this.em.findOne(Session, {
      user: { id: userId },
      isRevoked: false,
      expiresAt: { $gt: new Date() },
    });
  }

  async validateRefreshToken(session: Session, token: string): Promise<boolean> {
    return bcrypt.compare(token, session.refreshTokenHash);
  }

  async revoke(session: Session): Promise<void> {
    session.isRevoked = true;
    await this.em.flush();
  }

  /**
   * Revoke every active session for a user and force-disconnect any
   * live Socket.io connections they have across all four gateways.
   *
   * `reason` is persisted on each updated row (via the `revoke_reason`
   * column added in Migration20260409_apple_s2s) and also echoed to
   * the mobile client via the `client:state: killed` realtime event
   * so the Flutter app can route to a reason-specific post-kill screen.
   *
   * Typical reasons:
   *   - 'token_reuse'           — refresh token replay detected
   *   - 'manual_logout'         — user-initiated logout (single session path
   *                                uses `revoke(session)` instead; this is
   *                                for admin-initiated all-sessions kills)
   *   - 'apple_consent_revoked' — Apple S2S consent-revoked webhook
   *   - 'apple_account_delete'  — Apple S2S account-delete webhook
   *   - 'admin_ban'             — admin suspended/banned the user
   *
   * Idempotent: a second call for the same user returns 0 updated rows
   * because the WHERE clause filters `isRevoked = false`.
   *
   * Realtime kill is fire-and-forget — socket errors are logged but
   * never block the DB revocation. The DB is the authoritative source
   * of truth; sockets are a best-effort UX improvement.
   */
  async revokeAllForUser(userId: string, reason?: string): Promise<number> {
    const updated = await this.em.nativeUpdate(
      Session,
      { user: { id: userId }, isRevoked: false },
      {
        isRevoked: true,
        ...(reason ? { revokeReason: reason } : {}),
      },
    );

    // Fire the realtime kill out-of-band. Swallow errors so DB state
    // (which IS the source of truth) is never rolled back by a socket
    // failure.
    this.realtimeRevocation.killUser(userId, reason).catch((err) => {
      this.logger.warn(
        `Realtime revocation failed for ${userId}: ${(err as Error).message}`,
      );
    });

    return updated;
  }
}
