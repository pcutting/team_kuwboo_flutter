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
import { corsOrigins } from '../../config/cors-origins';

interface LocationUpdatePayload {
  latitude: number;
  longitude: number;
}

interface NearbyEnteredPayload {
  id: string;
  name: string;
  distanceKm: number;
}

interface WaveReceivedPayload {
  id: string;
  fromUserId: string;
  fromUserName: string;
  message?: string;
}

@WebSocketGateway({ namespace: '/proximity', cors: { origin: corsOrigins(), credentials: true } })
@UseGuards(WsAuthGuard)
export class ProximityGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(ProximityGateway.name);

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;

    if (userId) {
      client.join(`user:${userId}`);
    }

    this.logger.log(
      `Client connected to proximity: ${client.id} (user: ${userId})`,
    );
  }

  handleDisconnect(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(
      `Client disconnected from proximity: ${client.id} (user: ${userId})`,
    );
  }

  @SubscribeMessage('location:update')
  handleLocationUpdate(
    @ConnectedSocket() _client: Socket,
    @MessageBody() data: LocationUpdatePayload,
  ): { event: string; data: { received: boolean } } {
    if (data?.latitude == null || data?.longitude == null) {
      return { event: 'location:error', data: { received: false } };
    }

    return { event: 'location:ack', data: { received: true } };
  }

  /**
   * Emit to a specific user when someone enters their radius.
   * Call this from YoyoService when proximity is detected.
   */
  emitNearbyEntered(userId: string, nearbyUser: NearbyEnteredPayload): void {
    this.server.to(`user:${userId}`).emit('nearby:entered', nearbyUser);
  }

  /**
   * Emit when someone leaves a user's radius.
   * Call this from YoyoService when proximity is lost.
   */
  emitNearbyLeft(userId: string, leftUserId: string): void {
    this.server
      .to(`user:${userId}`)
      .emit('nearby:left', { userId: leftUserId });
  }

  /**
   * Emit wave received to a specific user.
   * Call this from YoyoService when a wave is sent.
   */
  emitWaveReceived(userId: string, wave: WaveReceivedPayload): void {
    this.server.to(`user:${userId}`).emit('wave:received', wave);
  }
}
