/**
 * Bootstrap the real AppModule-backed Nest application for E2E tests.
 *
 * Migrations were applied once by `test/setup.ts`, so this just wires up
 * the Nest DI container and HTTP adapter. Global pipes mirror
 * `src/main.ts` so validation behaves identically to prod.
 */
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { MikroORM } from '@mikro-orm/core';
import { JwtService } from '@nestjs/jwt';
import { AppModule } from '../../src/app.module';

/**
 * Explicit historical order. The migration filenames for 2026-04-14
 * all share the same date, so the Migrator's default glob sort puts
 * `content_interest_tags` before `interests` — breaking the FK.
 * Production environments applied these sequentially (one per commit),
 * so their `mikro_orm_migrations` table already reflects the correct
 * order and this is purely a fresh-bootstrap concern.
 */
const MIGRATION_ORDER = [
  'Migration20260403_init',
  'Migration20260413_baseline_schema',
  'Migration20260414_identity_core',
  'Migration20260414_interests',
  'Migration20260414_seed_interests',
  'Migration20260414_profile_completeness_nudge',
  'Migration20260414_content_interest_tags',
  'Migration20260417_auth_and_credibility',
  'Migration20260419_user_consent_user_agent',
];

async function runMigrationsIfNeeded(orm: MikroORM): Promise<void> {
  const migrator = orm.getMigrator();
  const executed = new Set(
    (await migrator.getExecutedMigrations()).map((m) => m.name),
  );
  for (const name of MIGRATION_ORDER) {
    if (executed.has(name)) continue;
    await migrator.up({ migrations: [name] });
  }
}

export interface TestAppContext {
  app: INestApplication;
  em: EntityManager;
  jwtService: JwtService;
  close: () => Promise<void>;
}

export async function bootstrapTestApp(): Promise<TestAppContext> {
  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleRef.createNestApplication({ bufferLogs: true });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.init();

  // Apply migrations using the live MikroORM instance managed by Nest.
  const orm = app.get(MikroORM);
  await runMigrationsIfNeeded(orm);

  const em = app.get<EntityManager>(EntityManager).fork();
  const jwtService = app.get(JwtService);

  const close = async (): Promise<void> => {
    await app.close();
  };

  return { app, em, jwtService, close };
}
