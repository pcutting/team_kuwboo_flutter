import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { BullModule } from '@nestjs/bullmq';
import { ScheduleModule } from '@nestjs/schedule';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { UnderscoreNamingStrategy } from '@mikro-orm/core';
import { Migrator } from '@mikro-orm/migrations';
import { LoggerModule } from 'nestjs-pino';
import { randomUUID } from 'crypto';
import type { IncomingMessage } from 'http';

import databaseConfig from './config/database.config';
import redisConfig from './config/redis.config';
import jwtConfig from './config/jwt.config';
import appleConfig from './config/apple.config';

import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';

import { HealthModule } from './modules/health/health.module';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { DevicesModule } from './modules/devices/devices.module';
import { MediaModule } from './modules/media/media.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ConsentModule } from './modules/consent/consent.module';
import { AdminModule } from './modules/admin/admin.module';
import { ContentModule } from './modules/content/content.module';
import { InteractionsModule } from './modules/interactions/interactions.module';
import { CommentsModule } from './modules/comments/comments.module';
import { ConnectionsModule } from './modules/connections/connections.module';
import { ReportsModule } from './modules/reports/reports.module';
import { FeedModule } from './modules/feed/feed.module';
import { MessagingModule } from './modules/messaging/messaging.module';
import { MarketplaceModule } from './modules/marketplace/marketplace.module';
import { SponsoredModule } from './modules/sponsored/sponsored.module';
import { PresenceModule } from './modules/presence/presence.module';
import { YoyoModule } from './modules/yoyo/yoyo.module';
import { BotsModule } from './modules/bots/bots.module';
import { CredentialsModule } from './modules/credentials/credentials.module';
import { TrustModule } from './modules/trust/trust.module';
import { InterestsModule } from './modules/interests/interests.module';
import { DatingModule } from './modules/dating/dating.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, redisConfig, jwtConfig, appleConfig],
      envFilePath: '.env',
    }),

    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL ?? 'info',
        genReqId: (req: IncomingMessage) => {
          const existing = req.headers['x-request-id'];
          if (typeof existing === 'string' && existing.length > 0) return existing;
          return randomUUID();
        },
        customProps: () => ({ service: 'kuwboo-api' }),
        // Redact sensitive fields from structured logs. Pino redact paths use
        // object-path syntax; wildcards match any single segment.
        redact: {
          paths: [
            'req.headers.authorization',
            'req.headers.cookie',
            'req.headers["x-api-key"]',
            'req.body.password',
            'req.body.passwordHash',
            'req.body.refreshToken',
            'req.body.identityToken',
            'req.body.payload',
            'req.body.otp',
            'req.body.code',
            'res.headers["set-cookie"]',
            '*.email',
            '*.phone',
            '*.passwordHash',
          ],
          censor: '[REDACTED]',
        },
        transport:
          process.env.NODE_ENV === 'development'
            ? { target: 'pino-pretty', options: { singleLine: true, translateTime: 'SYS:HH:MM:ss.l' } }
            : undefined,
      },
    }),

    MikroOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        driver: PostgreSqlDriver,
        host: config.get('database.host'),
        port: config.get('database.port'),
        dbName: config.get('database.name'),
        user: config.get('database.user'),
        password: config.get('database.password'),
        entities: ['dist/**/*.entity.js'],
        entitiesTs: ['src/**/*.entity.ts'],
        namingStrategy: UnderscoreNamingStrategy,
        driverOptions: /\.rds\.amazonaws\.com$/.test(
          config.get<string>('database.host') || '',
        )
          ? { connection: { ssl: { rejectUnauthorized: false } } }
          : undefined,
        pool: { min: 2, max: 10 },
        extensions: [Migrator],
        migrations: {
          tableName: 'mikro_orm_migrations',
          path: 'dist/database/migrations',
          pathTs: 'src/database/migrations',
          transactional: true,
          allOrNothing: true,
        },
        debug: config.get('NODE_ENV') === 'development',
      }),
    }),

    ThrottlerModule.forRoot([
      {
        ttl: parseInt(process.env.THROTTLE_TTL || '60000', 10),
        limit: parseInt(process.env.THROTTLE_LIMIT || '120', 10),
      },
    ]),

    ScheduleModule.forRoot(),

    BullModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        connection: {
          host: config.get('redis.host'),
          port: config.get('redis.port'),
        },
      }),
    }),

    HealthModule,
    UsersModule,
    AuthModule,
    DevicesModule,
    MediaModule,
    NotificationsModule,
    ConsentModule,
    AdminModule,
    ContentModule,
    InteractionsModule,
    CommentsModule,
    ConnectionsModule,
    ReportsModule,
    FeedModule,
    MessagingModule,
    MarketplaceModule,
    SponsoredModule,
    PresenceModule,
    YoyoModule,
    BotsModule,
    CredentialsModule,
    TrustModule,
    InterestsModule,
    DatingModule,
  ],
  providers: [
    { provide: APP_FILTER, useClass: HttpExceptionFilter },
    { provide: APP_INTERCEPTOR, useClass: TransformInterceptor },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
