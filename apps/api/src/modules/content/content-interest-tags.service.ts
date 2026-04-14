import { Injectable, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { ContentInterestTag } from './entities/content-interest-tag.entity';
import { Content } from './entities/content.entity';
import { Interest } from '../interests/entities/interest.entity';

export interface GetContentIdsByInterestOpts {
  limit?: number;
  offset?: number;
}

/**
 * Manages the Content <-> Interest join table. Sits between the content
 * module's creator/admin tagging endpoints and D2d's signal emitter,
 * which reads `getInterestIdsForContent` on the hot path (per-like,
 * per-view).
 */
@Injectable()
export class ContentInterestTagsService {
  constructor(private readonly em: EntityManager) {}

  /**
   * Idempotent tag. Re-tagging an already-tagged (content, interest)
   * pair is a no-op (the row is kept, not duplicated).
   */
  async tagContent(
    contentId: string,
    interestIds: string[],
    assignedByUserId?: string,
    confidence: number = 1.0,
  ): Promise<void> {
    if (!interestIds.length) return;

    const uniqueIds = Array.from(new Set(interestIds));

    // Validate content + interests exist.
    const content = await this.em.findOne(Content, { id: contentId });
    if (!content) throw new NotFoundException('Content not found');

    const interests = await this.em.find(Interest, { id: { $in: uniqueIds } });
    if (interests.length !== uniqueIds.length) {
      throw new NotFoundException('One or more interests not found');
    }

    const existing = await this.em.find(ContentInterestTag, {
      content: { id: contentId },
      interest: { id: { $in: uniqueIds } },
    });
    const existingIds = new Set(existing.map((r) => r.interest.id));

    for (const interest of interests) {
      if (existingIds.has(interest.id)) continue;
      this.em.create(ContentInterestTag, {
        content,
        interest,
        assignedByUser: assignedByUserId
          ? this.em.getReference('User', assignedByUserId)
          : undefined,
        confidence,
      } as any);
    }
    await this.em.flush();
  }

  /**
   * Replace the full set of interest tags for a content with the provided
   * list. Tags not in `interestIds` are removed; new ones are inserted.
   */
  async replaceTags(
    contentId: string,
    interestIds: string[],
    assignedByUserId?: string,
    confidence: number = 1.0,
  ): Promise<string[]> {
    const content = await this.em.findOne(Content, { id: contentId });
    if (!content) throw new NotFoundException('Content not found');

    const uniqueIds = Array.from(new Set(interestIds));

    if (uniqueIds.length) {
      const interests = await this.em.find(Interest, { id: { $in: uniqueIds } });
      if (interests.length !== uniqueIds.length) {
        throw new NotFoundException('One or more interests not found');
      }
    }

    const existing = await this.em.find(ContentInterestTag, {
      content: { id: contentId },
    });

    const desired = new Set(uniqueIds);
    const toRemove = existing.filter((r) => !desired.has(r.interest.id));
    const existingIds = new Set(existing.map((r) => r.interest.id));
    const toAdd = uniqueIds.filter((id) => !existingIds.has(id));

    for (const row of toRemove) this.em.remove(row);

    for (const interestId of toAdd) {
      this.em.create(ContentInterestTag, {
        content,
        interest: this.em.getReference(Interest, interestId),
        assignedByUser: assignedByUserId
          ? this.em.getReference('User', assignedByUserId)
          : undefined,
        confidence,
      } as any);
    }

    await this.em.flush();
    return uniqueIds;
  }

  async untagContent(contentId: string, interestIds: string[]): Promise<void> {
    if (!interestIds.length) return;
    await this.em.nativeDelete(ContentInterestTag, {
      content: { id: contentId },
      interest: { id: { $in: interestIds } },
    });
  }

  /**
   * Hot path: called by InteractionsService.emitInterestSignal on every
   * like / video view. Returns just the IDs — cheap projection.
   */
  async getInterestIdsForContent(contentId: string): Promise<string[]> {
    const rows = (await this.em
      .createQueryBuilder(ContentInterestTag, 'cit')
      .select(['cit.interest_id'])
      .where({ content: contentId })
      .execute('all', false)) as unknown as Array<{ interest_id: string }>;
    return rows.map((r) => r.interest_id);
  }

  /**
   * Reverse lookup: all content IDs currently tagged with `interestId`.
   * Used by the recommendation engine.
   */
  async getContentIdsByInterest(
    interestId: string,
    opts: GetContentIdsByInterestOpts = {},
  ): Promise<string[]> {
    const { limit = 100, offset = 0 } = opts;
    const rows = (await this.em
      .createQueryBuilder(ContentInterestTag, 'cit')
      .select(['cit.content_id'])
      .where({ interest: interestId })
      .orderBy({ 'cit.assigned_at': 'DESC' })
      .limit(limit)
      .offset(offset)
      .execute('all', false)) as unknown as Array<{ content_id: string }>;
    return rows.map((r) => r.content_id);
  }

  /** Full populated view — used by the public GET endpoint. */
  async getTagsForContent(contentId: string): Promise<ContentInterestTag[]> {
    return this.em.find(
      ContentInterestTag,
      { content: { id: contentId } },
      { populate: ['interest'] },
    );
  }
}
