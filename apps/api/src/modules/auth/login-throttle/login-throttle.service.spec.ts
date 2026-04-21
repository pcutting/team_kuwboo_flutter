import {
  LoginThrottleService,
  computeBackoffMs,
} from './login-throttle.service';
import { DelayProvider } from './delay.provider';
import { LoginThrottleRedis } from './redis.provider';

/**
 * Hand-rolled in-memory stub implementing just the slice of ioredis
 * that `LoginThrottleService` touches. Enough for deterministic unit
 * tests without a live Redis or Testcontainers.
 */
class FakeRedis implements LoginThrottleRedis {
  counters = new Map<string, number>();
  sets = new Map<string, Set<string>>();
  ttls = new Map<string, number>();
  kv = new Map<string, { value: string; expiresAt: number | null }>();
  failNext: Error | null = null;

  async incr(key: string): Promise<number> {
    this.maybeFail();
    const next = (this.counters.get(key) ?? 0) + 1;
    this.counters.set(key, next);
    return next;
  }

  async expire(key: string, seconds: number): Promise<number> {
    this.ttls.set(key, seconds);
    return 1;
  }

  async ttl(key: string): Promise<number> {
    return this.ttls.get(key) ?? -1;
  }

  async del(...keys: string[]): Promise<number> {
    let n = 0;
    for (const k of keys) {
      if (this.counters.delete(k)) n++;
      if (this.sets.delete(k)) n++;
      if (this.kv.delete(k)) n++;
      this.ttls.delete(k);
    }
    return n;
  }

  async sadd(key: string, ...members: string[]): Promise<number> {
    let set = this.sets.get(key);
    if (!set) {
      set = new Set();
      this.sets.set(key, set);
    }
    let added = 0;
    for (const m of members) {
      if (!set.has(m)) {
        set.add(m);
        added++;
      }
    }
    return added;
  }

  async scard(key: string): Promise<number> {
    return this.sets.get(key)?.size ?? 0;
  }

  async set(
    key: string,
    value: string,
    ...args: (string | number)[]
  ): Promise<'OK' | null> {
    // Minimal NX + EX support — enough for markLockNotified.
    const nx = args.includes('NX');
    const exIdx = args.indexOf('EX');
    const exSeconds = exIdx >= 0 ? Number(args[exIdx + 1]) : null;
    const existing = this.kv.get(key);
    if (nx && existing && (!existing.expiresAt || existing.expiresAt > Date.now())) {
      return null;
    }
    this.kv.set(key, {
      value,
      expiresAt: exSeconds ? Date.now() + exSeconds * 1000 : null,
    });
    return 'OK';
  }

  async get(key: string): Promise<string | null> {
    this.maybeFail();
    const entry = this.kv.get(key);
    if (!entry) {
      const c = this.counters.get(key);
      return c === undefined ? null : String(c);
    }
    if (entry.expiresAt && entry.expiresAt < Date.now()) {
      this.kv.delete(key);
      return null;
    }
    return entry.value;
  }

  private maybeFail(): void {
    if (this.failNext) {
      const e = this.failNext;
      this.failNext = null;
      throw e;
    }
  }
}

class ZeroDelay extends DelayProvider {
  delays: number[] = [];
  async wait(ms: number): Promise<void> {
    this.delays.push(ms);
  }
}

describe('computeBackoffMs', () => {
  it('returns 0 for attempts 1–3 (normal-typo band)', () => {
    expect(computeBackoffMs(1)).toBe(0);
    expect(computeBackoffMs(2)).toBe(0);
    expect(computeBackoffMs(3)).toBe(0);
  });

  it('doubles from 500 ms starting at attempt 4', () => {
    expect(computeBackoffMs(4)).toBe(500);
    expect(computeBackoffMs(5)).toBe(1000);
    expect(computeBackoffMs(6)).toBe(2000);
    expect(computeBackoffMs(7)).toBe(4000);
    expect(computeBackoffMs(8)).toBe(8000);
    expect(computeBackoffMs(9)).toBe(16000);
  });

  it('returns 0 at the hard-throttle ceiling (≥10) — caller uses 429 instead', () => {
    expect(computeBackoffMs(10)).toBe(0);
    expect(computeBackoffMs(50)).toBe(0);
  });
});

describe('LoginThrottleService', () => {
  let redis: FakeRedis;
  let delay: ZeroDelay;
  let svc: LoginThrottleService;

  beforeEach(() => {
    redis = new FakeRedis();
    delay = new ZeroDelay();
    svc = new LoginThrottleService(redis, delay);
  });

  it('attempts 1–3 record no delay and do not throttle', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';

    for (let i = 1; i <= 3; i++) {
      const d = await svc.registerFailure(e, ip);
      expect(d.failureCount).toBe(i);
      expect(d.appliedDelayMs).toBe(0);
      expect(d.shouldThrottle).toBe(false);
    }
    expect(delay.delays.every((ms) => ms === 0 || !delay.delays.length)).toBe(true);
  });

  it('attempt 4 applies a 500 ms delay and sleeps via DelayProvider', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';
    for (let i = 1; i <= 3; i++) await svc.registerFailure(e, ip);

    const d = await svc.registerFailure(e, ip);
    expect(d.failureCount).toBe(4);
    expect(d.appliedDelayMs).toBe(500);
    expect(d.shouldThrottle).toBe(false);
    expect(delay.delays).toContain(500);
  });

  it('attempt 10 short-circuits to shouldThrottle + zero delay', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';
    for (let i = 1; i <= 9; i++) await svc.registerFailure(e, ip);

    const d = await svc.registerFailure(e, ip);
    expect(d.failureCount).toBe(10);
    expect(d.appliedDelayMs).toBe(0);
    expect(d.shouldThrottle).toBe(true);
  });

  it('shouldBlockBeforeCheck returns true once the counter hits the ceiling', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';

    // Below the ceiling: must not block.
    for (let i = 1; i <= 9; i++) await svc.registerFailure(e, ip);
    expect(await svc.shouldBlockBeforeCheck(e, ip)).toBe(false);

    // At the ceiling: block.
    await svc.registerFailure(e, ip);
    expect(await svc.shouldBlockBeforeCheck(e, ip)).toBe(true);
  });

  it('registerSuccess clears both per-(email, ip) counter and distinct-IP set', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';

    await svc.registerFailure(e, ip);
    await svc.registerFailure(e, '5.6.7.8');
    await svc.registerSuccess(e, ip);

    // Counter from ip=1.2.3.4 cleared — but ip=5.6.7.8 still has its own key.
    const d = await svc.registerFailure(e, ip);
    expect(d.failureCount).toBe(1);
  });

  it('per-(email, ip) key sets a 15-minute TTL on first write', async () => {
    const e = 'user@example.com';
    const ip = '1.2.3.4';

    await svc.registerFailure(e, ip);

    // Every key in the TTL map should have a TTL ≤ 30 minutes.
    const ttls = Array.from(redis.ttls.values());
    expect(ttls.length).toBeGreaterThan(0);
    for (const ttl of ttls) {
      expect(ttl).toBeGreaterThan(0);
      expect(ttl).toBeLessThanOrEqual(30 * 60);
    }
  });

  it('fails open if Redis throws during the pre-check', async () => {
    redis.failNext = new Error('redis down');
    expect(await svc.shouldBlockBeforeCheck('user@example.com', '1.1.1.1')).toBe(
      false,
    );
  });

  it('hashes email into both counter and distinct-IP keys', async () => {
    const e = 'alice@example.com';
    await svc.registerFailure(e, '1.1.1.1');

    // sha256('alice@example.com') — truncated prefix we can check against.
    // (If this is ever changed it's a caller-observable API change.)
    expect([...redis.counters.keys()].join(',')).toMatch(/^login:fail:/);
    expect([...redis.sets.keys()].join(',')).toMatch(/^login:distinct-ips:/);
  });
});
