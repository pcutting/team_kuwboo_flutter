import { UseGuards, Logger } from '@nestjs/common';
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';

interface NotificationPayload {
  id: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
}

interface NotificationReadPayload {
  notificationId: string;
}

@WebSocketGateway({ namespace: '/notifications', cors: true })
@UseGuards(WsAuthGuard)
export class NotificationGateway implements OnGatewayConnection {
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(NotificationGateway.name);

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;

    if (userId) {
      client.join(`user:${userId}`);
    }

    this.logger.log(
      `Client connected to notifications: ${client.id} (user: ${userId})`,
    );
  }

  @SubscribeMessage('notification:read')
  handleRead(
    @ConnectedSocket() _client: Socket,
    @MessageBody() data: NotificationReadPayload,
  ): { event: string; data: { id: string } } {
    const notificationId = data?.notificationId;

    if (!notificationId) {
      return { event: 'notification:error', data: { id: '' } };
    }

    return {
      event: 'notification:read:ack',
      data: { id: notificationId },
    };
  }

  /**
   * Emit a new notification to a specific user.
   * Call this from NotificationsService when a notification is created.
   */
  emitNotification(userId: string, notification: NotificationPayload): void {
    this.server
      .to(`user:${userId}`)
      .emit('notification:new', notification);
  }

  /**
   * Emit a badge count update to a specific user.
   * Call this from NotificationsService when unread count changes.
   */
  emitBadgeUpdate(userId: string, count: number): void {
    this.server
      .to(`user:${userId}`)
      .emit('badge:update', { count });
  }

  /**
   * Force-disconnect all sockets belonging to a user after sending a
   * `client:state` killed event. Called from RealtimeRevocationService
   * when sessions are revoked — e.g. via an Apple S2S consent-revoked
   * or account-delete notification.
   *
   * Fires and discards errors so session-revocation paths are not
   * blocked by socket failures. The Redis adapter (when enabled) fans
   * out the room broadcast cross-instance; `fetchSockets()` on a room
   * name is the canonical way to iterate remote sockets in a cluster.
   */
  async killUser(
    userId: string,
    payload: { state: string; reason?: string },
  ): Promise<void> {
    const room = `user:${userId}`;
    this.server.to(room).emit('client:state', payload);
    try {
      const sockets = await this.server.in(room).fetchSockets();
      for (const socket of sockets) {
        socket.disconnect(true);
      }
    } catch (err) {
      this.logger.warn(
        `killUser disconnect failed for ${userId}: ${(err as Error).message}`,
      );
    }
  }
}
