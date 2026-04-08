import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Connection } from './entities/connection.entity';
import { Block } from './entities/block.entity';
import { ConnectionContext, ConnectionStatus, ModuleScope } from '../../common/enums';

@Injectable()
export class ConnectionsService {
  constructor(private readonly em: EntityManager) {}

  async follow(fromUserId: string, toUserId: string, moduleScope?: ModuleScope): Promise<Connection> {
    const existing = await this.em.findOne(Connection, {
      fromUser: { id: fromUserId },
      toUser: { id: toUserId },
      context: ConnectionContext.FOLLOW,
      moduleScope: moduleScope ?? null,
    });

    if (existing) throw new ConflictException('Already following');

    const connection = this.em.create(Connection, {
      fromUser: this.em.getReference('User', fromUserId),
      toUser: this.em.getReference('User', toUserId),
      context: ConnectionContext.FOLLOW,
      status: ConnectionStatus.ACTIVE,
      moduleScope,
    } as any);

    await this.em.flush();
    return connection;
  }

  async unfollow(fromUserId: string, toUserId: string, moduleScope?: ModuleScope): Promise<void> {
    const connection = await this.em.findOne(Connection, {
      fromUser: { id: fromUserId },
      toUser: { id: toUserId },
      context: ConnectionContext.FOLLOW,
      moduleScope: moduleScope ?? null,
    });

    if (!connection) throw new NotFoundException('Not following');
    this.em.remove(connection);
    await this.em.flush();
  }

  async sendFriendRequest(fromUserId: string, toUserId: string): Promise<Connection> {
    const connection = this.em.create(Connection, {
      fromUser: this.em.getReference('User', fromUserId),
      toUser: this.em.getReference('User', toUserId),
      context: ConnectionContext.FRIEND,
      status: ConnectionStatus.PENDING,
    } as any);

    await this.em.flush();
    return connection;
  }

  async acceptFriendRequest(connectionId: string, userId: string): Promise<Connection> {
    const connection = await this.em.findOne(Connection, {
      id: connectionId,
      toUser: { id: userId },
      context: ConnectionContext.FRIEND,
      status: ConnectionStatus.PENDING,
    });

    if (!connection) throw new NotFoundException('Friend request not found');
    connection.status = ConnectionStatus.ACTIVE;
    connection.confirmedAt = new Date();
    await this.em.flush();
    return connection;
  }

  async rejectFriendRequest(connectionId: string, userId: string): Promise<void> {
    const connection = await this.em.findOne(Connection, {
      id: connectionId,
      toUser: { id: userId },
      context: ConnectionContext.FRIEND,
      status: ConnectionStatus.PENDING,
    });

    if (!connection) throw new NotFoundException('Friend request not found');
    connection.status = ConnectionStatus.REJECTED;
    await this.em.flush();
  }

  async getFollowers(userId: string, limit = 20, offset = 0): Promise<{ items: Connection[]; total: number }> {
    const [items, total] = await this.em.findAndCount(
      Connection,
      { toUser: { id: userId }, context: ConnectionContext.FOLLOW, status: ConnectionStatus.ACTIVE },
      { populate: ['fromUser'], limit, offset, orderBy: { createdAt: 'DESC' } },
    );
    return { items, total };
  }

  async getFollowing(userId: string, limit = 20, offset = 0): Promise<{ items: Connection[]; total: number }> {
    const [items, total] = await this.em.findAndCount(
      Connection,
      { fromUser: { id: userId }, context: ConnectionContext.FOLLOW, status: ConnectionStatus.ACTIVE },
      { populate: ['toUser'], limit, offset, orderBy: { createdAt: 'DESC' } },
    );
    return { items, total };
  }

  async getFollowingIds(userId: string, moduleScope?: ModuleScope): Promise<string[]> {
    const where: any = {
      fromUser: { id: userId },
      context: ConnectionContext.FOLLOW,
      status: ConnectionStatus.ACTIVE,
    };
    if (moduleScope) {
      where.$or = [{ moduleScope }, { moduleScope: null }];
    }

    const connections = await this.em.find(Connection, where, { fields: ['toUser'] });
    return connections.map((c) => c.toUser.id);
  }

  async block(blockerId: string, blockedId: string): Promise<Block> {
    const block = this.em.create(Block, {
      blocker: this.em.getReference('User', blockerId),
      blocked: this.em.getReference('User', blockedId),
    } as any);

    // Remove any existing connections between the two users
    await this.em.nativeDelete(Connection, {
      $or: [
        { fromUser: { id: blockerId }, toUser: { id: blockedId } },
        { fromUser: { id: blockedId }, toUser: { id: blockerId } },
      ],
    });

    await this.em.flush();
    return block;
  }

  async unblock(blockerId: string, blockedId: string): Promise<void> {
    await this.em.nativeDelete(Block, { blocker: { id: blockerId }, blocked: { id: blockedId } });
  }

  async getBlockedIds(userId: string): Promise<string[]> {
    const blocks = await this.em.find(Block, {
      $or: [{ blocker: { id: userId } }, { blocked: { id: userId } }],
    });
    return blocks.map((b) => (b.blocker.id === userId ? b.blocked.id : b.blocker.id));
  }

  async getBlocks(userId: string): Promise<Block[]> {
    return this.em.find(Block, { blocker: { id: userId } }, { populate: ['blocked'] });
  }
}
