import { Injectable } from '@nestjs/common';

/**
 * In-memory counters for the login-throttle subsystem (issue #174).
 *
 * This is deliberately the minimum-viable metrics surface:
 *   - three integer counters
 *   - no HTTP endpoint
 *   - no Prometheus / OTEL wiring
 *   - no persistence across restarts
 *
 * A future metrics module will scrape these into a /metrics endpoint
 * or push them to StatsD / CloudWatch — see
 * `docs/team/internal/AUTH_BRUTE_FORCE_DEFENSE.md`. Until that wiring
 * lands, tests can assert on the counter values and ops can eyeball
 * them via a health-check panel.
 */
@Injectable()
export class LoginMetricsService {
  private counters = {
    login_failures_total: 0,
    login_throttled_total: 0,
    login_soft_lock_total: 0,
  };

  incrementFailure(): void {
    this.counters.login_failures_total += 1;
  }

  incrementThrottled(): void {
    this.counters.login_throttled_total += 1;
  }

  incrementSoftLock(): void {
    this.counters.login_soft_lock_total += 1;
  }

  snapshot(): Readonly<{
    login_failures_total: number;
    login_throttled_total: number;
    login_soft_lock_total: number;
  }> {
    return { ...this.counters };
  }

  /** Test helper — never call from production code. */
  reset(): void {
    this.counters = {
      login_failures_total: 0,
      login_throttled_total: 0,
      login_soft_lock_total: 0,
    };
  }
}
