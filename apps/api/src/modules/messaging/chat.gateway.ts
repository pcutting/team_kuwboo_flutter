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

interface MessageSendPayload {
  threadId: string;
  text: string;
}

interface ThreadPayload {
  threadId: string;
}

@WebSocketGateway({ namespace: '/chat', cors: true })
@UseGuards(WsAuthGuard)
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(ChatGateway.name);

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client connected: ${client.id} (user: ${userId})`);

    // Join user's personal room for DM notifications
    if (userId) {
      client.join(`user:${userId}`);
    }
  }

  handleDisconnect(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client disconnected: ${client.id} (user: ${userId})`);
  }

  @SubscribeMessage('message:send')
  handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: MessageSendPayload,
  ): void {
    const threadId = data?.threadId;
    const text = data?.text;

    if (!threadId || !text) {
      return;
    }

    this.server.to(`thread:${threadId}`).emit('message:new', {
      threadId,
      senderId: client.data.userId,
      text,
      createdAt: new Date().toISOString(),
    });
  }

  @SubscribeMessage('thread:join')
  handleJoinThread(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ThreadPayload,
  ): { event: string; data: { threadId: string; joined: boolean } } {
    const threadId = data?.threadId;

    if (!threadId) {
      return {
        event: 'thread:error',
        data: { threadId: '', joined: false },
      };
    }

    client.join(`thread:${threadId}`);
    this.logger.debug(
      `User ${client.data.userId} joined thread ${threadId}`,
    );

    return {
      event: 'thread:joined',
      data: { threadId, joined: true },
    };
  }

  @SubscribeMessage('thread:leave')
  handleLeaveThread(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ThreadPayload,
  ): { event: string; data: { threadId: string; left: boolean } } {
    const threadId = data?.threadId;

    if (!threadId) {
      return {
        event: 'thread:error',
        data: { threadId: '', left: false },
      };
    }

    client.leave(`thread:${threadId}`);
    this.logger.debug(
      `User ${client.data.userId} left thread ${threadId}`,
    );

    return {
      event: 'thread:left',
      data: { threadId, left: true },
    };
  }

  @SubscribeMessage('typing:start')
  handleTypingStart(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ThreadPayload,
  ): void {
    const threadId = data?.threadId;
    if (!threadId) return;

    client.to(`thread:${threadId}`).emit('typing:update', {
      threadId,
      userId: client.data.userId,
      isTyping: true,
    });
  }

  @SubscribeMessage('typing:stop')
  handleTypingStop(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ThreadPayload,
  ): void {
    const threadId = data?.threadId;
    if (!threadId) return;

    client.to(`thread:${threadId}`).emit('typing:update', {
      threadId,
      userId: client.data.userId,
      isTyping: false,
    });
  }

  /**
   * Emit a message event to all participants in a thread.
   * Call this from services when a message is persisted.
   */
  emitToThread(threadId: string, event: string, data: any): void {
    this.server.to(`thread:${threadId}`).emit(event, data);
  }

  /**
   * Emit an event to a specific user's personal room.
   * Call this from services for DM notifications or alerts.
   */
  emitToUser(userId: string, event: string, data: any): void {
    this.server.to(`user:${userId}`).emit(event, data);
  }
}
