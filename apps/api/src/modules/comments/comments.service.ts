import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { raw } from '@mikro-orm/core';
import { Comment } from './entities/comment.entity';
import { Content } from '../content/entities/content.entity';

@Injectable()
export class CommentsService {
  constructor(private readonly em: EntityManager) {}

  async create(userId: string, contentId: string, text: string, parentCommentId?: string): Promise<Comment> {
    const content = await this.em.findOneOrFail(Content, { id: contentId });

    const comment = this.em.create(Comment, {
      content,
      author: this.em.getReference('User', userId),
      text,
      parentComment: parentCommentId ? this.em.getReference(Comment, parentCommentId) : undefined,
    } as any);

    await this.em.flush();

    // Update counters
    await this.em.nativeUpdate(Content, { id: contentId }, { commentCount: raw('comment_count + 1') } as any);
    if (parentCommentId) {
      await this.em.nativeUpdate(Comment, { id: parentCommentId }, { replyCount: raw('reply_count + 1') } as any);
    }

    return comment;
  }

  async getForContent(contentId: string, cursor?: string, limit = 20): Promise<{ items: Comment[]; nextCursor?: string }> {
    const where: any = { content: { id: contentId }, parentComment: null };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(Comment, where, {
      populate: ['author', 'replies', 'replies.author'],
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      items.pop();
      nextCursor = items[items.length - 1].createdAt.toISOString();
    }

    return { items, nextCursor };
  }

  async toggleLike(commentId: string): Promise<Comment> {
    const comment = await this.em.findOneOrFail(Comment, { id: commentId });
    comment.likeCount++;
    await this.em.flush();
    return comment;
  }

  async softDelete(commentId: string, userId: string, isAdmin = false): Promise<void> {
    const comment = await this.em.findOne(Comment, { id: commentId }, { populate: ['author'] });
    if (!comment) throw new NotFoundException('Comment not found');
    if (!isAdmin && comment.author.id !== userId) throw new ForbiddenException('Not the comment author');
    comment.deletedAt = new Date();
    await this.em.flush();
  }
}
