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

interface AuctionPayload {
  auctionId: string;
}

interface BidPlacedPayload {
  bidderId: string;
  amountCents: number;
  createdAt: string;
}

@WebSocketGateway({ namespace: '/marketplace', cors: { origin: corsOrigins(), credentials: true } })
@UseGuards(WsAuthGuard)
export class MarketplaceGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(MarketplaceGateway.name);

  handleConnection(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client connected: ${client.id} (user: ${userId})`);

    // Join user's personal room for outbid notifications
    if (userId) {
      client.join(`user:${userId}`);
    }
  }

  handleDisconnect(client: Socket): void {
    const userId = client.data?.userId;
    this.logger.log(`Client disconnected: ${client.id} (user: ${userId})`);
  }

  @SubscribeMessage('auction:subscribe')
  handleSubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: AuctionPayload,
  ): { event: string; data: { auctionId: string; subscribed: boolean } } {
    const auctionId = data?.auctionId;

    if (!auctionId) {
      return {
        event: 'auction:error',
        data: { auctionId: '', subscribed: false },
      };
    }

    client.join(`auction:${auctionId}`);
    this.logger.debug(
      `User ${client.data.userId} subscribed to auction ${auctionId}`,
    );

    return {
      event: 'auction:subscribed',
      data: { auctionId, subscribed: true },
    };
  }

  @SubscribeMessage('auction:unsubscribe')
  handleUnsubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: AuctionPayload,
  ): { event: string; data: { auctionId: string; unsubscribed: boolean } } {
    const auctionId = data?.auctionId;

    if (!auctionId) {
      return {
        event: 'auction:error',
        data: { auctionId: '', unsubscribed: false },
      };
    }

    client.leave(`auction:${auctionId}`);
    this.logger.debug(
      `User ${client.data.userId} unsubscribed from auction ${auctionId}`,
    );

    return {
      event: 'auction:unsubscribed',
      data: { auctionId, unsubscribed: true },
    };
  }

  /**
   * Emit a bid placement to all auction watchers.
   * Call this from MarketplaceService when a bid is recorded.
   */
  emitBidPlaced(auctionId: string, bid: BidPlacedPayload): void {
    this.server.to(`auction:${auctionId}`).emit('bid:placed', {
      auctionId,
      ...bid,
    });
  }

  /**
   * Emit auction end to all watchers.
   * Call this from MarketplaceService when an auction closes.
   */
  emitAuctionEnded(auctionId: string, winnerId: string | null): void {
    this.server.to(`auction:${auctionId}`).emit('auction:ended', {
      auctionId,
      winnerId,
    });
  }

  /**
   * Notify a specific user they have been outbid.
   * Call this from MarketplaceService when a higher bid is placed.
   */
  emitOutbid(
    userId: string,
    auctionId: string,
    newAmountCents: number,
  ): void {
    this.server.to(`user:${userId}`).emit('bid:outbid', {
      auctionId,
      newAmountCents,
    });
  }
}
