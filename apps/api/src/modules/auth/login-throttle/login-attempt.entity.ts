import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';

/**
 * Outcome discriminator for a single login attempt row. Covers both
 * success and the brute-force-relevant failure modes so the auth
 * audit trail is uniform across outcomes.
 */
export enum LoginAttemptOutcome {
  /** Credentials matched — normal login. */
  SUCCESS = 'SUCCESS',
  /** Email resolved to a real user, but the password was wrong. */
  WRONG_PASSWORD = 'WRONG_PASSWORD',
  /** No user exists for this email (enumeration still returns 401 to the caller). */
  UNKNOWN_EMAIL = 'UNKNOWN_EMAIL',
  /**
   * Account-level soft-lock already active when the attempt arrived,
   * OR newly triggered by cross-IP credential-stuffing detection on
   * this attempt.
   */
  LOCKED_OUT = 'LOCKED_OUT',
  /**
   * Per-(email, ip) exponential backoff escalated to a hard 429. No
   * password check was performed — throttling kicks in before credential
   * comparison so wall-clock is independent of success vs. failure.
   */
  THROTTLED = 'THROTTLED',
}

/**
 * Append-only audit row for every POST /auth/email/login attempt.
 *
 * Privacy note: we deliberately store a sha256 digest of the email
 * (hex, 64 chars) rather than the raw address. This lets us correlate
 * by email for rate-limiting / support purposes without leaking the
 * email back out of the audit store. The server-side rate-limiter
 * keys off the same hash.
 *
 * The `ip_address` column is varchar rather than inet so IPv6 edge
 * cases, proxy-set "unknown" sentinels, and the occasional missing
 * value can all round-trip without postgres rejecting the insert.
 */
@Entity({ tableName: 'auth_login_attempts' })
@Index({ properties: ['emailHash', 'attemptedAt'] })
@Index({ properties: ['ipAddress', 'attemptedAt'] })
export class LoginAttempt {
  [OptionalProps]?: 'attemptedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  /** sha256 hex digest of the normalised email (lowercase, trimmed). */
  @Property({ type: 'varchar', length: 64 })
  emailHash!: string;

  /** Raw source IP as reported by Fastify's trust-proxy layer. Nullable for edge cases. */
  @Property({ type: 'varchar', length: 45, nullable: true })
  ipAddress?: string;

  /** Best-effort User-Agent string. Truncated by the client-side driver if very long. */
  @Property({ type: 'text', nullable: true })
  userAgent?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  attemptedAt: Date = new Date();

  @Enum({ items: () => LoginAttemptOutcome, columnType: 'varchar(32)' })
  outcome!: LoginAttemptOutcome;
}
