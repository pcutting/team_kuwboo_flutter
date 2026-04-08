import { UseGuards, Logger } from '@nestjs/common';
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';

interface FeedSubscription {
  tab: string;
}

interface ContentNewPayload {
  type: string;
  id: string;
  creatorId: string;
}

interface EngagementUpdatePayload {
  contentId: string;
  likeCount: number;
  commentCount: number;
}

const VALID_FEED_TABS = ['video', 'social', 'marketplace', 'dating'] as const;
type FeedTab = (typeof VALID_FEED_TABS)[number];

@WebSocketGateway({ namespace: '/feed', cors: true })
@UseGuards(WsAuthGuard)
export class FeedGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(FeedGateway.name);

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client connected: ${client.id} (user: ${userId})`);
  }

  handleDisconnect(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client disconnected: ${client.id} (user: ${userId})`);
  }

  @SubscribeMessage('feed:subscribe')
  handleSubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: FeedSubscription,
  ): { event: string; data: { room: string; joined: boolean } } {
    const tab = data?.tab;

    if (!tab || !VALID_FEED_TABS.includes(tab as FeedTab)) {
      return {
        event: 'feed:error',
        data: { room: tab, joined: false },
      };
    }

    const room = `feed:${tab}`;
    client.join(room);
    this.logger.debug(
      `User ${client.data.userId} joined room ${room}`,
    );

    return {
      event: 'feed:subscribed',
      data: { room, joined: true },
    };
  }

  @SubscribeMessage('feed:unsubscribe')
  handleUnsubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: FeedSubscription,
  ): { event: string; data: { room: string; left: boolean } } {
    const tab = data?.tab;

    if (!tab || !VALID_FEED_TABS.includes(tab as FeedTab)) {
      return {
        event: 'feed:error',
        data: { room: tab, left: false },
      };
    }

    const room = `feed:${tab}`;
    client.leave(room);
    this.logger.debug(
      `User ${client.data.userId} left room ${room}`,
    );

    return {
      event: 'feed:unsubscribed',
      data: { room, left: true },
    };
  }

  /**
   * Emit a new content event to the appropriate feed room.
   * Call this from services when content is published.
   */
  emitContentNew(tab: FeedTab, payload: ContentNewPayload): void {
    this.server.to(`feed:${tab}`).emit('content:new', payload);
  }

  /**
   * Emit an engagement update to the appropriate feed room.
   * Call this from services when likes/comments change.
   */
  emitEngagementUpdate(
    tab: FeedTab,
    payload: EngagementUpdatePayload,
  ): void {
    this.server.to(`feed:${tab}`).emit('engagement:update', payload);
  }
}
