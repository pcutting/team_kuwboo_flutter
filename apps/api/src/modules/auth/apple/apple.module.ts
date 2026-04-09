import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import appleConfig from '../../../config/apple.config';
import { AppleJwksService } from './apple-jwks.service';
import { AppleNotificationEvent } from './entities/apple-notification-event.entity';

/**
 * Apple-specific auth primitives.
 *
 * Currently exports AppleJwksService which verifies Apple's ES256 JWS
 * for both sign-in identity tokens and Server-to-Server notifications.
 *
 * Registers the AppleNotificationEvent entity so MikroORM can inject
 * its repository into the upcoming ingest and handler services.
 *
 * Future members:
 *   - AppleTokenService (for the /auth/token and /auth/revoke flows
 *     that require a client secret signed with the .p8 private key)
 *   - AppleNotificationIngestService (S2S webhook ingest, PR 5)
 *   - AppleNotificationHandlerService (event processing, PR 6)
 */
@Module({
  imports: [
    ConfigModule.forFeature(appleConfig),
    MikroOrmModule.forFeature([AppleNotificationEvent]),
  ],
  providers: [AppleJwksService],
  exports: [AppleJwksService, MikroOrmModule],
})
export class AppleAuthModule {}
