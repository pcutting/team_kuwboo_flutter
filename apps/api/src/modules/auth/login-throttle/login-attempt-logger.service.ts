import { Injectable, Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { createHash } from 'crypto';
import { LoginAttempt, LoginAttemptOutcome } from './login-attempt.entity';

export interface LoginAttemptLogInput {
  email: string;
  ipAddress?: string;
  userAgent?: string;
  outcome: LoginAttemptOutcome;
}

/**
 * Writes an append-only row to `auth_login_attempts` for every login
 * attempt — success and failure. Raw emails never hit the table;
 * `LoginAttemptLogger.hashEmail()` produces a deterministic sha256 hex
 * digest so rate-limiters and forensics can correlate by user without
 * storing PII.
 *
 * Write failures are logged and swallowed: the audit trail is a
 * best-effort signal, and losing a row must never block a legitimate
 * login or mask a 401 as a 500.
 */
@Injectable()
export class LoginAttemptLogger {
  private readonly logger = new Logger(LoginAttemptLogger.name);

  constructor(private readonly em: EntityManager) {}

  /**
   * Deterministic email → sha256 hex. Normalisation (lowercase, trim)
   * is the caller's responsibility — the service that logs an attempt
   * has already run the email through `AuthService.normaliseEmail()`.
   */
  static hashEmail(normalisedEmail: string): string {
    return createHash('sha256').update(normalisedEmail).digest('hex');
  }

  async log(input: LoginAttemptLogInput): Promise<void> {
    try {
      const fork = this.em.fork();
      const row = fork.create(LoginAttempt, {
        emailHash: LoginAttemptLogger.hashEmail(input.email),
        ipAddress: input.ipAddress,
        userAgent: input.userAgent,
        outcome: input.outcome,
      } as any);
      await fork.persistAndFlush(row);
    } catch (err) {
      // Audit-trail failures must never kill a login request. Log
      // loudly so ops sees the miss, but return normally.
      this.logger.error(
        `Failed to persist login attempt (outcome=${input.outcome}): ${(err as Error).message}`,
      );
    }
  }
}
