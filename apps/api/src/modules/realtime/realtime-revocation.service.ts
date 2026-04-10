import { Injectable, Logger } from '@nestjs/common';
import { NotificationGateway } from '../notifications/notification.gateway';
import { ChatGateway } from '../messaging/chat.gateway';
import { FeedGateway } from '../feed/feed.gateway';
import { PresenceGateway } from '../presence/presence.gateway';

/**
 * Cross-gateway session termination.
 *
 * When a user's sessions are revoked — either directly by an admin, via
 * token-reuse detection, or because Apple sent us a consent-revoked /
 * account-delete S2S notification — we need to disconnect every live
 * Socket.io connection for that user across all four namespaces and
 * tell the mobile client WHY via a `client:state: 'killed'` event so
 * the app can route to the appropriate post-kill screen.
 *
 * Each gateway exposes its own `killUser(userId, payload)` because each
 * uses slightly different targeting:
 *   - notifications / chat / presence: broadcast to `user:${id}` room,
 *     then `fetchSockets` + `disconnect` to force-close
 *   - feed: no per-user room exists (feed sockets only join `feed:${tab}`
 *     rooms), so iterate namespace sockets and filter by socket.data.userId
 *
 * We fan out in parallel with Promise.all so a slow gateway can't block
 * the others. Individual gateway errors are swallowed inside each
 * `killUser` implementation — they log but never throw — so the session
 * DB revocation path (the authoritative source of truth) is never
 * blocked by socket failures.
 *
 * Once a Redis adapter is wired into Socket.io, the room-based fan-out
 * becomes cluster-wide automatically. The per-namespace fetchSockets()
 * calls transparently reach remote instances via the adapter.
 */
@Injectable()
export class RealtimeRevocationService {
  private readonly logger = new Logger(RealtimeRevocationService.name);

  constructor(
    private readonly notifications: NotificationGateway,
    private readonly chat: ChatGateway,
    private readonly feed: FeedGateway,
    private readonly presence: PresenceGateway,
  ) {}

  /**
   * Terminate every realtime connection for the given user across all
   * four gateways. The `reason` is echoed to the mobile client so the
   * Flutter app can route to a reason-specific screen (e.g. "Your
   * Apple ID was deleted" vs. "You revoked access via Apple ID
   * settings" vs. generic "Signed out").
   */
  async killUser(userId: string, reason?: string): Promise<void> {
    const payload = { state: 'killed', reason };

    this.logger.log(
      `Killing all realtime sessions for user ${userId} (reason: ${reason ?? 'unspecified'})`,
    );

    await Promise.all([
      this.notifications.killUser(userId, payload),
      this.chat.killUser(userId, payload),
      this.feed.killUser(userId, payload),
      this.presence.killUser(userId, payload),
    ]);
  }
}
