/**
 * Global Jest teardown for E2E tests. Stops the Postgres + Redis
 * containers started in `setup.ts`.
 */
export default async function globalTeardown(): Promise<void> {
  const refs = (globalThis as unknown as {
    __E2E_CONTAINERS__?: {
      pg: { stop: () => Promise<unknown> };
      redis: { stop: () => Promise<unknown> };
    };
  }).__E2E_CONTAINERS__;

  if (!refs) return;

  await Promise.allSettled([refs.pg.stop(), refs.redis.stop()]);
  // eslint-disable-next-line no-console
  console.log('[e2e teardown] containers stopped');
}
