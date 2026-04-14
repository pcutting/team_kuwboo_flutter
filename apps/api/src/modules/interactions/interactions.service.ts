import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { raw } from '@mikro-orm/core';
import { InteractionState } from './entities/interaction-state.entity';
import { InteractionEvent } from './entities/interaction-event.entity';
import { Content } from '../content/entities/content.entity';
import { InteractionStateType, InteractionEventType, ContentType } from '../../common/enums';
import { InterestSignalsService } from '../interests/interest-signals.service';
import { ContentInterestTagsService } from '../content/content-interest-tags.service';

@Injectable()
export class InteractionsService {
  constructor(
    private readonly em: EntityManager,
    private readonly interestSignals: InterestSignalsService,
    private readonly contentInterestTags: ContentInterestTagsService,
  ) {}

  async toggleLike(userId: string, contentId: string): Promise<{ liked: boolean }> {
    const result = await this.toggleState(userId, contentId, InteractionStateType.LIKE, 'like_count');
    if (result) {
      // Fire-and-forget behavioural signal emission. Only when the user
      // transitions to liked (not on unlike).
      await this.emitInterestSignal(userId, contentId, 'content.liked');
    }
    return { liked: result };
  }

  async toggleSave(userId: string, contentId: string): Promise<{ saved: boolean }> {
    const result = await this.toggleState(userId, contentId, InteractionStateType.SAVE, 'save_count');
    return { saved: result };
  }

  async logView(userId: string, contentId: string): Promise<void> {
    await this.logEvent(userId, contentId, InteractionEventType.VIEW);
    await this.em.nativeUpdate(Content, { id: contentId }, { viewCount: raw('view_count + 1') } as any);
    // Treat a view on a VIDEO as the "video.watched" signal analogue until
    // we have proper playback-duration tracking.
    const content = await this.em.findOne(Content, { id: contentId });
    if (content?.type === ContentType.VIDEO) {
      await this.emitInterestSignal(userId, contentId, 'video.watched');
    }
  }

  /**
   * Maps a Content to its associated interest IDs (via
   * ContentInterestTagsService — see D3b) and enqueues a bump job.
   * No-ops for untagged content (expected for legacy content until
   * the auto-classifier backfills tags).
   */
  private async emitInterestSignal(
    userId: string,
    contentId: string,
    source: string,
  ): Promise<void> {
    const interestIds = await this.contentInterestTags.getInterestIdsForContent(contentId);
    if (interestIds.length === 0) return;
    await this.interestSignals.enqueueBump({ userId, interestIds, source });
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
