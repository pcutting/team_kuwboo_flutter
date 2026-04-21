import { Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

/**
 * DI token for a shared ioredis client dedicated to the login-throttle
 * subsystem. Reuses the same Redis instance BullMQ uses (config values
 * `redis.host` / `redis.port`) but keeps a separate connection so
 * queue traffic can't stall an auth-path GETSET / INCR round trip.
 *
 * The connection uses `lazyConnect: true` so unit tests that never hit
 * the throttle path don't pay the TCP setup cost.
 */
export const LOGIN_THROTTLE_REDIS = Symbol('LOGIN_THROTTLE_REDIS');

/**
 * Minimal shape `LoginThrottleService` depends on. Declared as a
 * structural interface rather than pinning to `Redis` so unit tests
 * can hand-roll an in-memory stub without implementing the full
 * ioredis surface.
 */
export interface LoginThrottleRedis {
  incr(key: string): Promise<number>;
  expire(key: string, seconds: number): Promise<number>;
  ttl(key: string): Promise<number>;
  del(...keys: string[]): Promise<number>;
  sadd(key: string, ...members: string[]): Promise<number>;
  scard(key: string): Promise<number>;
  set(
    key: string,
    value: string,
    ...args: (string | number)[]
  ): Promise<'OK' | null>;
  get(key: string): Promise<string | null>;
}

/**
 * Creates the ioredis client as a NestJS provider. Bound to the
 * `LOGIN_THROTTLE_REDIS` token so any future login-throttle consumer
 * can inject the same singleton.
 */
export const loginThrottleRedisProvider: Provider = {
  provide: LOGIN_THROTTLE_REDIS,
  inject: [ConfigService],
  useFactory: (config: ConfigService): LoginThrottleRedis => {
    const client = new Redis({
      host: config.get<string>('redis.host'),
      port: config.get<number>('redis.port'),
      lazyConnect: true,
      maxRetriesPerRequest: 3,
      // Keep the connection sticky — reconnecting on each op would
      // add measurable latency to the login hot path.
      enableOfflineQueue: true,
    });

    // Opportunistic connect. A failure here is non-fatal; ioredis
    // reconnects on the next command. Surfacing the error here just
    // gives a clearer boot-log message.
    client.connect().catch(() => {
      // Swallow: ioredis will surface per-command errors the first
      // time throttle middleware actually tries to use it.
    });

    // ioredis's overloaded `set` signature doesn't line up with the
    // structural interface we want here (we only use the
    // `SET key value NX EX <seconds>` form). A narrow adapter keeps
    // the call-site readable without reaching for `any`.
    const adapted: LoginThrottleRedis = {
      incr: (key) => client.incr(key),
      expire: (key, seconds) => client.expire(key, seconds),
      ttl: (key) => client.ttl(key),
      del: (...keys) => client.del(...keys),
      sadd: (key, ...members) => client.sadd(key, ...members),
      scard: (key) => client.scard(key),
      get: (key) => client.get(key),
      set: async (key, value, ...args) => {
        // Cast through unknown to avoid the variadic overload puzzle
        // — at this point we trust the caller passed a valid
        // SET ... [NX] [EX n] combination.
        const res = await (client.set as unknown as (
          ...a: unknown[]
        ) => Promise<'OK' | null>)(key, value, ...args);
        return res;
      },
    };

    return adapted;
  },
};
