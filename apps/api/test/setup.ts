/**
 * Global Jest setup for E2E tests.
 *
 * Starts Postgres + Redis containers via Testcontainers, exposes their
 * connection coordinates on `process.env` for the NestJS AppModule to
 * pick up, runs all MikroORM migrations against the fresh Postgres
 * instance, then stashes the container refs on `globalThis` so
 * `teardown.ts` can stop them.
 */
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { GenericContainer, Wait } from 'testcontainers';

export default async function globalSetup(): Promise<void> {
  // eslint-disable-next-line no-console
  console.log('\n[e2e setup] starting Postgres + Redis containers...');

  // postgis/postgis image ships Postgres 16 + PostGIS, which the initial
  // migration requires via `CREATE EXTENSION postgis`.
  const pg = await new PostgreSqlContainer('postgis/postgis:16-3.4')
    .withDatabase('kuwboo')
    .withUsername('kuwboo_admin')
    .withPassword('test_password')
    .start();

  const redis = await new GenericContainer('redis:7-alpine')
    .withExposedPorts(6379)
    .withWaitStrategy(Wait.forLogMessage(/Ready to accept connections/))
    .start();

  process.env.NODE_ENV = 'test';
  process.env.DB_HOST = pg.getHost();
  process.env.DB_PORT = String(pg.getMappedPort(5432));
  process.env.DB_NAME = 'kuwboo';
  process.env.DB_USER = 'kuwboo_admin';
  process.env.DB_PASSWORD = 'test_password';
  process.env.REDIS_HOST = redis.getHost();
  process.env.REDIS_PORT = String(redis.getMappedPort(6379));
  process.env.JWT_ACCESS_SECRET = 'e2e-access-secret-fixed-for-tests';
  process.env.JWT_REFRESH_SECRET = 'e2e-refresh-secret-fixed-for-tests';
  process.env.JWT_ACCESS_EXPIRY = '15m';
  process.env.JWT_REFRESH_EXPIRY = '7d';
  // Disable AWS Secrets loading during tests (main.ts is not called, but
  // guard anyway in case a future helper invokes the bootstrap).
  process.env.AWS_LOAD_SECRETS = '0';

  // eslint-disable-next-line no-console
  console.log(
    `[e2e setup] Postgres on ${pg.getHost()}:${pg.getMappedPort(5432)}, ` +
      `Redis on ${redis.getHost()}:${redis.getMappedPort(6379)}`,
  );

  // Migrations are applied later, inside the Nest test app bootstrap
  // (see helpers/test-app.ts). Running `MikroORM.init` here in the Jest
  // globalSetup process triggers a "Map.prototype.set called on
  // incompatible receiver" error when Nest's subsequent MikroORM
  // instance re-discovers entities via the module registry.

  // Stash refs for teardown. Using a symbol-keyed property avoids clashes
  // with any other globals.
  (globalThis as unknown as {
    __E2E_CONTAINERS__: { pg: typeof pg; redis: typeof redis };
  }).__E2E_CONTAINERS__ = { pg, redis };
}
