import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { raw } from '@mikro-orm/core';
import { Content } from '../content/entities/content.entity';
import { ConnectionsService } from '../connections/connections.service';
import { ContentStatus, ContentType, ModuleScope } from '../../common/enums';

export interface FeedQuery {
  tab: 'video' | 'social' | 'shop' | 'home';
  cursor?: string;
  limit?: number;
  userId: string;
}

export interface FeedResult {
  items: Content[];
  nextCursor?: string;
  hasMore: boolean;
}

const TAB_TYPES: Record<string, ContentType[]> = {
  video: [ContentType.VIDEO],
  social: [ContentType.POST],
  shop: [ContentType.PRODUCT],
  home: [ContentType.VIDEO, ContentType.POST],
};

@Injectable()
export class FeedService {
  constructor(
    private readonly em: EntityManager,
    private readonly connectionsService: ConnectionsService,
  ) {}

  async getFeed(query: FeedQuery): Promise<FeedResult> {
    const limit = Math.min(query.limit || 20, 50);
    const blockedIds = await this.connectionsService.getBlockedIds(query.userId);

    const types = TAB_TYPES[query.tab] || TAB_TYPES.home;

    const where: any = {
      status: ContentStatus.ACTIVE,
      type: { $in: types },
    };

    if (blockedIds.length > 0) {
      where.creator = { id: { $nin: blockedIds } };
    }

    if (query.cursor) {
      where.createdAt = { $lt: new Date(query.cursor) };
    }

    const items = await this.em.find(Content, where, {
      populate: ['creator'],
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
    });

    let nextCursor: string | undefined;
    const hasMore = items.length > limit;
    if (hasMore) {
      items.pop();
      nextCursor = items[items.length - 1].createdAt.toISOString();
    }

    return { items, nextCursor, hasMore };
  }

  async getFollowingFeed(query: FeedQuery, moduleScope?: ModuleScope): Promise<FeedResult> {
    const limit = Math.min(query.limit || 20, 50);
    const followingIds = await this.connectionsService.getFollowingIds(query.userId, moduleScope);

    if (followingIds.length === 0) {
      return { items: [], hasMore: false };
    }

    const types = TAB_TYPES[query.tab] || TAB_TYPES.home;

    const where: any = {
      status: ContentStatus.ACTIVE,
      type: { $in: types },
      creator: { id: { $in: followingIds } },
    };

    if (query.cursor) {
      where.createdAt = { $lt: new Date(query.cursor) };
    }

    const items = await this.em.find(Content, where, {
      populate: ['creator'],
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
    });

    let nextCursor: string | undefined;
    const hasMore = items.length > limit;
    if (hasMore) {
      items.pop();
      nextCursor = items[items.length - 1].createdAt.toISOString();
    }

    return { items, nextCursor, hasMore };
  }

  async getTrending(tab: string, limit = 20): Promise<Content[]> {
    const types = TAB_TYPES[tab] || TAB_TYPES.home;
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    return this.em.find(
      Content,
      {
        status: ContentStatus.ACTIVE,
        type: { $in: types },
        createdAt: { $gt: sevenDaysAgo },
      },
      {
        populate: ['creator'],
        orderBy: { likeCount: 'DESC', commentCount: 'DESC', createdAt: 'DESC' },
        limit,
      },
    );
  }

  async getDiscover(userId: string, tab: string, limit = 20): Promise<Content[]> {
    const types = TAB_TYPES[tab] || TAB_TYPES.home;
    const blockedIds = await this.connectionsService.getBlockedIds(userId);

    const where: any = {
      status: ContentStatus.ACTIVE,
      type: { $in: types },
    };

    if (blockedIds.length > 0) {
      where.creator = { id: { $nin: blockedIds } };
    }

    // Random discovery — simple approach, shuffle in app layer
    const items = await this.em.find(Content, where, {
      populate: ['creator'],
      orderBy: { createdAt: 'DESC' },
      limit: limit * 3,
    });

    // Fisher-Yates shuffle
    for (let i = items.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [items[i], items[j]] = [items[j], items[i]];
    }

    return items.slice(0, limit);
  }
}
