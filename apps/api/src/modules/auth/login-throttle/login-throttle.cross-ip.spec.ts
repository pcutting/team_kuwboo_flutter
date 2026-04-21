import { LoginThrottleService } from './login-throttle.service';
import { DelayProvider } from './delay.provider';
import { LoginThrottleRedis } from './redis.provider';

/**
 * Phase 2 unit coverage for LoginThrottleService — the distinct-IP
 * set + account-lock trigger. Uses a hand-rolled in-memory Redis stub
 * and a zero-delay DelayProvider so the whole schedule runs in under
 * 10 ms even though the production code sleeps up to 16 s on attempt 9.
 */
class FakeRedis implements LoginThrottleRedis {
  counters = new Map<string, number>();
  sets = new Map<string, Set<string>>();
  ttls = new Map<string, number>();
  kv = new Map<string, { value: string; expiresAt: number | null }>();

  async incr(key: string): Promise<number> {
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
}

class ZeroDelay extends DelayProvider {
  async wait(_ms: number): Promise<void> {}
}

describe('LoginThrottleService cross-IP credential-stuffing detection', () => {
  let redis: FakeRedis;
  let svc: LoginThrottleService;

  beforeEach(() => {
    redis = new FakeRedis();
    svc = new LoginThrottleService(redis, new ZeroDelay());
  });

  it('does not trigger an account lock until the 3rd distinct IP', async () => {
    const e = 'target@example.com';

    const first = await svc.registerFailure(e, '1.1.1.1');
    expect(first.distinctIpCount).toBe(1);
    expect(first.accountLockTriggered).toBe(false);

    const second = await svc.registerFailure(e, '2.2.2.2');
    expect(second.distinctIpCount).toBe(2);
    expect(second.accountLockTriggered).toBe(false);
  });

  it('triggers on the 3rd distinct IP, AND stays triggered on the 4th IP', async () => {
    const e = 'target@example.com';

    await svc.registerFailure(e, '1.1.1.1');
    await svc.registerFailure(e, '2.2.2.2');
    const third = await svc.registerFailure(e, '3.3.3.3');
    expect(third.distinctIpCount).toBe(3);
    expect(third.accountLockTriggered).toBe(true);

    const fourth = await svc.registerFailure(e, '4.4.4.4');
    expect(fourth.distinctIpCount).toBe(4);
    expect(fourth.accountLockTriggered).toBe(true);
  });

  it('treats repeated failures from the same IP as one distinct IP', async () => {
    const e = 'target@example.com';
    for (let i = 0; i < 3; i++) {
      const d = await svc.registerFailure(e, '1.1.1.1');
      expect(d.distinctIpCount).toBe(1);
      expect(d.accountLockTriggered).toBe(false);
    }
  });

  it('does not trigger a lock when ipAddress is missing — unknown IPs cannot be counted', async () => {
    const e = 'target@example.com';
    for (let i = 0; i < 10; i++) {
      const d = await svc.registerFailure(e, undefined);
      expect(d.accountLockTriggered).toBe(false);
    }
  });

  it('markLockNotified is write-once within the TTL window (dedupe)', async () => {
    const e = 'target@example.com';
    const first = await svc.markLockNotified(e);
    expect(first).toBe(true);

    const second = await svc.markLockNotified(e);
    expect(second).toBe(false);

    // A different email is independent.
    const otherFirst = await svc.markLockNotified('other@example.com');
    expect(otherFirst).toBe(true);
  });
});
