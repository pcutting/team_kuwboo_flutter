import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { raw } from '@mikro-orm/core';
import { InteractionState } from './entities/interaction-state.entity';
import { InteractionEvent } from './entities/interaction-event.entity';
import { Content } from '../content/entities/content.entity';
import { InteractionStateType, InteractionEventType } from '../../common/enums';

@Injectable()
export class InteractionsService {
  constructor(private readonly em: EntityManager) {}

  async toggleLike(userId: string, contentId: string): Promise<{ liked: boolean }> {
    const result = await this.toggleState(userId, contentId, InteractionStateType.LIKE, 'like_count');
    return { liked: result };
  }

  async toggleSave(userId: string, contentId: string): Promise<{ saved: boolean }> {
    const result = await this.toggleState(userId, contentId, InteractionStateType.SAVE, 'save_count');
    return { saved: result };
  }

  async logView(userId: string, contentId: string): Promise<void> {
    await this.logEvent(userId, contentId, InteractionEventType.VIEW);
    await this.em.nativeUpdate(Content, { id: contentId }, { viewCount: raw('view_count + 1') } as any);
  }

  async logShare(userId: string, contentId: string, platform?: string): Promise<void> {
    await this.logEvent(userId, contentId, InteractionEventType.SHARE, platform ? { platform } : undefined);
    await this.em.nativeUpdate(Content, { id: contentId }, { shareCount: raw('share_count + 1') } as any);
  }

  async getUserInteractions(
    userId: string,
    contentId: string,
  ): Promise<{ liked: boolean; saved: boolean }> {
    const states = await this.em.find(InteractionState, {
      user: { id: userId },
      content: { id: contentId },
    });

    return {
      liked: states.some((s) => s.type === InteractionStateType.LIKE),
      saved: states.some((s) => s.type === InteractionStateType.SAVE),
    };
  }

  private async toggleState(
    userId: string,
    contentId: string,
    type: InteractionStateType,
    dbColumn: string,
  ): Promise<boolean> {
    const existing = await this.em.findOne(InteractionState, {
      user: { id: userId },
      content: { id: contentId },
      type,
    });

    if (existing) {
      this.em.remove(existing);
      await this.em.flush();
      await this.em.nativeUpdate(Content, { id: contentId }, { [dbColumn === 'like_count' ? 'likeCount' : 'saveCount']: raw(`${dbColumn} - 1`) } as any);
      return false;
    }

    const content = await this.em.findOneOrFail(Content, { id: contentId });
    this.em.create(InteractionState, {
      user: this.em.getReference('User', userId),
      content,
      type,
    } as any);
    await this.em.flush();
    await this.em.nativeUpdate(Content, { id: contentId }, { [dbColumn === 'like_count' ? 'likeCount' : 'saveCount']: raw(`${dbColumn} + 1`) } as any);
    return true;
  }

  private async logEvent(
    userId: string,
    contentId: string,
    type: InteractionEventType,
    metadata?: Record<string, unknown>,
  ): Promise<void> {
    const content = await this.em.findOneOrFail(Content, { id: contentId });
    this.em.create(InteractionEvent, {
      user: this.em.getReference('User', userId),
      content,
      type,
      metadata,
    } as any);
    await this.em.flush();
  }
}
