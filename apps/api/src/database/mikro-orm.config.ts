import { Options, UnderscoreNamingStrategy } from '@mikro-orm/core';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { Migrator } from '@mikro-orm/migrations';

/**
 * MikroORM configuration — shared between NestJS bootstrap and CLI.
 *
 * In NestJS: loaded via MikroOrmModule.forRootAsync() with ConfigService overrides.
 * In CLI: loaded directly via mikro-orm.config.ts (ts-node).
 */
const config: Options<PostgreSqlDriver> = {
  driver: PostgreSqlDriver,

  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  dbName: process.env.DB_NAME || 'kuwboo',
  user: process.env.DB_USER || 'kuwboo_admin',
  password: process.env.DB_PASSWORD || '',

  entities: ['dist/**/*.entity.js'],
  entitiesTs: ['src/**/*.entity.ts'],

  namingStrategy: UnderscoreNamingStrategy,

  // Never auto-sync in production — use migrations only
  schemaGenerator: {
    disableForeignKeys: false,
  },

  // RDS always requires SSL — gate on whether host looks like RDS rather than NODE_ENV
  // (so dev/staging environments pointing at RDS still negotiate SSL correctly).
  driverOptions: /\.rds\.amazonaws\.com$/.test(process.env.DB_HOST || '')
    ? { connection: { ssl: { rejectUnauthorized: false } } }
    : undefined,

  pool: {
    min: 2,
    max: 10,
  },

  extensions: [Migrator],

  migrations: {
    tableName: 'mikro_orm_migrations',
    path: 'dist/database/migrations',
    pathTs: 'src/database/migrations',
    glob: '!(*.d).{js,ts}',
    transactional: true,
    allOrNothing: true,
  },

  debug: process.env.NODE_ENV === 'development',
};

export default config;
