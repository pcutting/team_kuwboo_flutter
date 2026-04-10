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

interface PresenceEntry {
  socketId: string;
  connectedAt: Date;
}

interface PresenceQueryPayload {
  userIds: string[];
}

interface PresenceStatus {
  userId: string;
  status: 'ONLINE' | 'OFFLINE';
}

@WebSocketGateway({ namespace: '/presence', cors: true })
@UseGuards(WsAuthGuard)
export class PresenceGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(PresenceGateway.name);

  /** In-memory presence map. Replace with Redis adapter at scale. */
  private connectedUsers = new Map<string, PresenceEntry>();

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;

    if (userId) {
      this.connectedUsers.set(userId, {
        socketId: client.id,
        connectedAt: new Date(),
      });
      client.join(`user:${userId}`);
      this.server.emit('presence:update', { userId, status: 'ONLINE' });
    }

    this.logger.log(`Client connected: ${client.id} (user: ${userId})`);
  }

  handleDisconnect(client: Socket): void {
    const userId = client.data?.userId;

    if (userId) {
      this.connectedUsers.delete(userId);
      this.server.emit('presence:update', { userId, status: 'OFFLINE' });
    }

    this.logger.log(`Client disconnected: ${client.id} (user: ${userId})`);
  }

  @SubscribeMessage('presence:query')
  handleQuery(
    @ConnectedSocket() _client: Socket,
    @MessageBody() data: PresenceQueryPayload,
  ): { event: string; data: PresenceStatus[] } {
    const userIds = data?.userIds ?? [];

    const statuses: PresenceStatus[] = userIds.map((id) => ({
      userId: id,
      status: this.connectedUsers.has(id) ? 'ONLINE' : 'OFFLINE',
    }));

    return { event: 'presence:status', data: statuses };
  }

  /** Check if a user is currently connected. */
  isOnline(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }

  /** Return the total number of connected users. */
  getOnlineCount(): number {
    return this.connectedUsers.size;
  }

  /**
   * Force-disconnect a user's presence socket after sending a
   * `client:state` killed event. Called from RealtimeRevocationService
   * when sessions are revoked. The subsequent handleDisconnect handles
   * cleanup of the in-memory presence map and broadcasts the OFFLINE
   * transition automatically.
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
