import { Module } from '@nestjs/common';
import { NotificationsModule } from '../notifications/notifications.module';
import { MessagingModule } from '../messaging/messaging.module';
import { FeedModule } from '../feed/feed.module';
import { PresenceModule } from '../presence/presence.module';
import { RealtimeRevocationService } from './realtime-revocation.service';

/**
 * Realtime coordination primitives that cut across the individual
 * Socket.io gateway modules.
 *
 * Currently exports RealtimeRevocationService which fans out session
 * termination to all four gateways. Future members may include
 * cross-namespace broadcast helpers, Redis adapter wiring, and
 * presence-backed targeting utilities.
 *
 * This module is imported by SessionsModule so that
 * SessionsService.revokeAllForUser() can trigger a realtime kill after
 * flipping the is_revoked flag in the database.
 */
@Module({
  imports: [
    NotificationsModule,
    MessagingModule,
    FeedModule,
    PresenceModule,
  ],
  providers: [RealtimeRevocationService],
  exports: [RealtimeRevocationService],
})
export class RealtimeModule {}
