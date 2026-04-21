import { Injectable, Logger } from '@nestjs/common';
import { EmailService } from '../../email/email.service';
import { LoginThrottleService } from './login-throttle.service';

export interface LockNotificationContext {
  /** Email address the attacker is attempting (already normalised). */
  email: string;
  /** Source IP of the failing attempt that tripped the lock. */
  ipAddress?: string;
  /** User-Agent captured on the tripping attempt. */
  userAgent?: string;
  /**
   * Count of failed attempts in the trailing 24h window — approximate,
   * taken from the per-email distinct-IP set size times a small
   * multiplier. Consumed by the email template only; treat as a
   * hint, not a precise figure.
   */
  attemptsLast24h: number;
}

/**
 * Notifies both the user (via EmailService.sendLoginThreatNotice) and
 * ops (via structured `Logger.warn` with a canonical event key) when
 * the cross-IP credential-stuffing detector trips an account-level
 * soft-lock.
 *
 * Notification de-dupe: a Redis key `login:lock-notified:{email-hash}`
 * with 24h TTL is flipped on the first call via
 * `LoginThrottleService.markLockNotified()`. Repeat lock triggers
 * inside the same 24h window don't re-email the user or re-log the
 * ops event.
 *
 * Admin notification is intentionally minimum-viable: a
 * `Logger.warn` with event key `AUTH_ACCOUNT_SOFT_LOCK` and a
 * JSON-friendly structured payload. A future workflow can scrape
 * pino logs, drive a Slack webhook, or push to CloudWatch Events
 * without needing this service to know about any of those
 * destinations.
 */
@Injectable()
export class LoginNotifierService {
  private readonly logger = new Logger(LoginNotifierService.name);

  constructor(
    private readonly emailService: EmailService,
    private readonly throttle: LoginThrottleService,
  ) {}

  /**
   * Handle a freshly-tripped account soft-lock. Fire-and-forget
   * semantics: errors are logged but never propagate, so a broken
   * mailer can't mask the 429 the caller is about to return to
   * the attacker.
   */
  async notifyAccountLocked(ctx: LockNotificationContext): Promise<void> {
    const shouldSend = await this.throttle.markLockNotified(ctx.email);
    if (!shouldSend) {
      // Already notified inside the 24h de-dupe window. Skip both
      // user email + ops log — a repeat trigger on the same account
      // within the window is noise, not news.
      return;
    }

    // Ops / admin log — a structured `warn` event with a fixed key
    // so log-scrapers can pick it up without regex pain. The
    // `event` field is the entry point; everything else is
    // human-debuggable context.
    this.logger.warn({
      event: 'AUTH_ACCOUNT_SOFT_LOCK',
      emailHash: hashForLog(ctx.email),
      ipAddress: ctx.ipAddress,
      userAgent: ctx.userAgent,
      attemptsLast24h: ctx.attemptsLast24h,
    });

    // User notification — best effort. We deliberately call the
    // raw email (not the hash) because EmailService needs a real
    // address to send to. Email contents come from the shared
    // `renderLoginThreatEmail` template so tone / wording stays
    // consistent with the rest of the auth-flow transactional
    // surface.
    try {
      await this.emailService.sendLoginThreatNotice({
        to: ctx.email,
        ipAddress: ctx.ipAddress ?? 'unknown',
        userAgent: ctx.userAgent ?? 'unknown',
        attemptsLast24h: ctx.attemptsLast24h,
      });
    } catch (err) {
      this.logger.error(
        `Failed to deliver login-threat notice for lock event: ${(err as Error).message}`,
      );
    }
  }
}

/**
 * Local helper — returns the first 12 chars of the sha256 digest
 * for structured logs. Enough for correlation across events; short
 * enough that nobody mistakes it for the raw email.
 */
function hashForLog(email: string): string {
  // Lazy import keeps the cost out of the cold-path.
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const { createHash } = require('crypto');
  return createHash('sha256').update(email).digest('hex').slice(0, 12);
}
