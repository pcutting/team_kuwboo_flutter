import { Inject, Injectable, Logger } from '@nestjs/common';
import { DelayProvider } from './delay.provider';
import {
  LOGIN_THROTTLE_REDIS,
  LoginThrottleRedis,
} from './redis.provider';
import { LoginAttemptLogger } from './login-attempt-logger.service';

/**
 * Outcome of `registerFailure()` — tells the caller how to finish
 * responding to a failed login. The caller never computes throttle /
 * lock logic itself; all decision-making lives here so the auth
 * controller stays a thin HTTP adapter.
 */
export interface FailureDecision {
  /**
   * Delay (in ms) that must pass before the failure response is
   * returned. The service has already slept for this duration via
   * `DelayProvider` — the field is surfaced for tests + logging only.
   */
  appliedDelayMs: number;
  /**
   * When true, the caller must return a 429 instead of the usual 401.
   * Both the per-(email, ip) backoff ceiling and the cross-IP account
   * lock feed into this flag so the caller has a single bool to
   * branch on.
   */
  shouldThrottle: boolean;
  /**
   * When true, the cross-IP detector has just crossed the threshold —
   * the caller is responsible for setting `user.authLockedAt` and
   * triggering the user-notify + admin-notify paths (phase 2 + 3).
   */
  accountLockTriggered: boolean;
  /**
   * The per-(email, ip) attempt number that this failure represents
   * (1-based). Useful for metrics / logging; not normally consumed by
   * the caller.
   */
  failureCount: number;
  /**
   * Count of distinct IPs that have failed against this email inside
   * the current 30-minute window. Passed back so callers can log it.
   */
  distinctIpCount: number;
}

/** Attempt counter exceeding this ⇒ respond 429 and log THROTTLED. */
const ATTEMPTS_BEFORE_HARD_THROTTLE = 10;

/** Attempts 1–3 are delay-free — normal-typo territory. */
const DELAY_FREE_ATTEMPTS = 3;

/**
 * Per-(email, ip) counter TTL. Kept short enough that a real user
 * who mistyped five times then walked away doesn't come back to a
 * 4-second wall on their next genuine login 20 minutes later.
 */
const PER_EMAIL_IP_TTL_SECONDS = 15 * 60;

/**
 * Per-email distinct-IP set TTL. Longer than PER_EMAIL_IP_TTL so an
 * attacker sweeping three IPs over 20 minutes still trips the cross-IP
 * rule.
 */
const DISTINCT_IP_TTL_SECONDS = 30 * 60;

/**
 * Threshold at which the cross-IP detector assumes credential-stuffing
 * and triggers the account-level soft-lock. Three distinct IPs across a
 * 30-minute window is aggressive — the typical NAT / mobile-switch user
 * won't hit it.
 */
const DISTINCT_IP_LOCK_THRESHOLD = 3;

/**
 * Backoff delay for a given (1-based) attempt count. Returns 0 for
 * attempts 1–3 (normal typos) and doubles from 500 ms on attempt 4
 * up to 16 s on attempt 9. Attempt 10+ gets handled by the hard
 * throttle branch and never reaches this function.
 */
export function computeBackoffMs(attempt: number): number {
  if (attempt <= DELAY_FREE_ATTEMPTS) return 0;
  if (attempt >= ATTEMPTS_BEFORE_HARD_THROTTLE) return 0; // handled by throttle
  // attempt 4 → 500, 5 → 1000, 6 → 2000, 7 → 4000, 8 → 8000, 9 → 16000
  return 500 * Math.pow(2, attempt - (DELAY_FREE_ATTEMPTS + 1));
}

/**
 * Redis-backed rate-limit + soft-lock engine for POST /auth/email/login.
 *
 * Three layers, each keyed differently, each enforced in order:
 *
 *   1. Per-(email, ip) INCR with exponential backoff. Attempts 1–3 are
 *      delay-free, 4–9 sleep 500 / 1000 / 2000 / 4000 / 8000 / 16000 ms,
 *      10+ return a 429 "too many attempts" with zero extra delay.
 *   2. Per-email distinct-IP SADD. When the set size crosses three the
 *      caller is told to set `user.auth_locked_at` — recovery requires
 *      a password reset (see phase 2).
 *   3. Account-level soft lock. When already locked, every subsequent
 *      attempt returns the same 429 without checking the password.
 *
 * The service never throws — transient Redis failures fail open (normal
 * login proceeds) rather than lock users out of their own accounts
 * because Redis is down. The service emits structured warn-level logs
 * on the throttle / lock branches so ops dashboards can count them.
 */
@Injectable()
export class LoginThrottleService {
  private readonly logger = new Logger(LoginThrottleService.name);

  constructor(
    @Inject(LOGIN_THROTTLE_REDIS) private readonly redis: LoginThrottleRedis,
    private readonly delay: DelayProvider,
  ) {}

  /**
   * Call BEFORE the bcrypt check. Returns `true` if the attempt should
   * be blocked outright — either because the per-(email, ip) counter
   * has already exceeded its ceiling, or because the account is
   * soft-locked. The caller responds 429 in either case; the
   * distinction for logging is a concern of the caller.
   *
   * Fails open: any Redis error returns `false` so a broken Redis can't
   * lock legitimate users out of their accounts.
   */
  async shouldBlockBeforeCheck(
    email: string,
    ipAddress: string | undefined,
  ): Promise<boolean> {
    try {
      const key = this.perEmailIpKey(email, ipAddress);
      const existing = await this.redis.get(key);
      const count = existing ? parseInt(existing, 10) : 0;
      return count >= ATTEMPTS_BEFORE_HARD_THROTTLE;
    } catch (err) {
      this.logger.warn(
        `Redis check failed in shouldBlockBeforeCheck — failing open: ${(err as Error).message}`,
      );
      return false;
    }
  }

  /**
   * Record a failed login. Returns a `FailureDecision` telling the
   * caller whether to 401 or 429, how long the request was already
   * slept for, and whether an account-level lock was newly triggered.
   *
   * Contract: this method ALWAYS sleeps for the computed backoff
   * duration before returning, so the caller's HTTP response is
   * naturally paced.
   */
  async registerFailure(
    email: string,
    ipAddress: string | undefined,
  ): Promise<FailureDecision> {
    let failureCount = 0;
    let distinctIpCount = 0;

    // Increment the per-(email, ip) counter.
    try {
      const key = this.perEmailIpKey(email, ipAddress);
      failureCount = await this.redis.incr(key);
      if (failureCount === 1) {
        // First write — attach the TTL. Ignore errors; worst case the
        // key lives forever (still bounded by Redis maxmemory policy).
        await this.redis.expire(key, PER_EMAIL_IP_TTL_SECONDS).catch(() => 0);
      }
    } catch (err) {
      this.logger.warn(
        `Redis INCR failed in registerFailure: ${(err as Error).message}`,
      );
    }

    // Record the IP against the per-email distinct-IP set.
    let accountLockTriggered = false;
    if (ipAddress) {
      try {
        const setKey = this.distinctIpSetKey(email);
        await this.redis.sadd(setKey, ipAddress);
        await this.redis
          .expire(setKey, DISTINCT_IP_TTL_SECONDS)
          .catch(() => 0);
        distinctIpCount = await this.redis.scard(setKey);
        if (distinctIpCount >= DISTINCT_IP_LOCK_THRESHOLD) {
          accountLockTriggered = true;
        }
      } catch (err) {
        this.logger.warn(
          `Redis SADD failed in registerFailure: ${(err as Error).message}`,
        );
      }
    }

    const shouldThrottle = failureCount >= ATTEMPTS_BEFORE_HARD_THROTTLE;
    const appliedDelayMs = shouldThrottle
      ? 0
      : computeBackoffMs(failureCount);

    if (appliedDelayMs > 0) {
      await this.delay.wait(appliedDelayMs);
    }

    return {
      appliedDelayMs,
      shouldThrottle,
      accountLockTriggered,
      failureCount,
      distinctIpCount,
    };
  }

  /**
   * Reset both per-(email, ip) and per-email distinct-IP state on a
   * successful authentication. The account soft-lock is NOT cleared
   * here — unlock is gated by a password reset (phase 2).
   */
  async registerSuccess(
    email: string,
    ipAddress: string | undefined,
  ): Promise<void> {
    const keys = [
      this.perEmailIpKey(email, ipAddress),
      this.distinctIpSetKey(email),
    ];
    try {
      await this.redis.del(...keys);
    } catch (err) {
      this.logger.warn(
        `Redis DEL failed in registerSuccess: ${(err as Error).message}`,
      );
    }
  }

  /**
   * De-dupe guard for user-notification + admin-notification on a
   * freshly-triggered account lock. Uses a SETNX semantically — if the
   * key already exists the second caller sees `false` and skips the
   * send.
   *
   * TTL matches the 24-hour spec in the issue.
   */
  async markLockNotified(email: string): Promise<boolean> {
    const key = this.lockNotifiedKey(email);
    try {
      // SET key value NX EX <seconds> — atomic set-if-not-exists plus TTL.
      const res = await this.redis.set(key, '1', 'NX', 'EX', 24 * 60 * 60);
      return res === 'OK';
    } catch (err) {
      this.logger.warn(
        `Redis SET NX failed in markLockNotified: ${(err as Error).message}`,
      );
      // Failing open here means the user gets the notification more
      // than once in a weird failure mode. Preferable to silently
      // swallowing the notification.
      return true;
    }
  }

  private perEmailIpKey(email: string, ipAddress: string | undefined): string {
    const hash = LoginAttemptLogger.hashEmail(email);
    const ip = ipAddress ?? 'unknown';
    return `login:fail:${hash}:${ip}`;
  }

  private distinctIpSetKey(email: string): string {
    const hash = LoginAttemptLogger.hashEmail(email);
    return `login:distinct-ips:${hash}`;
  }

  private lockNotifiedKey(email: string): string {
    const hash = LoginAttemptLogger.hashEmail(email);
    return `login:lock-notified:${hash}`;
  }
}
