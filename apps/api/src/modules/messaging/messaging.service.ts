import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Thread } from './entities/thread.entity';
import { ThreadParticipant } from './entities/thread-participant.entity';
import { Message } from './entities/message.entity';
import { User } from '../users/entities/user.entity';
import { CreateThreadDto } from './dto/create-thread.dto';
import { SendMessageDto } from './dto/send-message.dto';

@Injectable()
export class MessagingService {
  constructor(private readonly em: EntityManager) {}

  async createThread(user: User, dto: CreateThreadDto): Promise<Thread> {
    const recipient = await this.em.findOne(User, { id: dto.recipientId });
    if (!recipient) throw new NotFoundException('Recipient not found');

    // Check for existing thread between these two users with same moduleKey
    const existingParticipation = await this.em.find(ThreadParticipant, {
      user: user,
    });

    for (const tp of existingParticipation) {
      const thread = await this.em.findOne(Thread, { id: tp.thread.id });
      if (!thread) continue;
      if (dto.moduleKey && thread.moduleKey !== dto.moduleKey) continue;
      if (dto.contextId && thread.contextId !== dto.contextId) continue;

      const otherParticipant = await this.em.findOne(ThreadParticipant, {
        thread,
        user: recipient,
      });
      if (otherParticipant) {
        // Found existing thread
        return thread;
      }
    }

    // Create new thread
    const thread = this.em.create(Thread, {
      moduleKey: dto.moduleKey,
      contextId: dto.contextId,
    } as any);

    await this.em.flush();

    this.em.create(ThreadParticipant, { thread, user } as any);
    this.em.create(ThreadParticipant, { thread, user: recipient } as any);

    await this.em.flush();
    return thread;
  }

  async getThreads(
    userId: string,
    cursor?: string,
    limit = 20,
  ): Promise<{ items: any[]; nextCursor?: string }> {
    const participations = await this.em.find(
      ThreadParticipant,
      { user: userId },
      { populate: ['thread'] },
    );

    const threadIds = participations.map((p) => p.thread.id);
    if (threadIds.length === 0) return { items: [] };

    const where: Record<string, any> = { id: { $in: threadIds } };
    if (cursor) where.updatedAt = { $lt: new Date(cursor) };

    const threads = await this.em.find(Thread, where, {
      orderBy: { updatedAt: 'DESC' },
      limit: limit + 1,
    });

    const hasMore = threads.length > limit;
    if (hasMore) threads.pop();

    // Attach last message and participants to each thread
    const items = await Promise.all(
      threads.map(async (thread) => {
        const lastMessage = await this.em.findOne(
          Message,
          { thread },
          { orderBy: { createdAt: 'DESC' }, populate: ['sender'] },
        );
        const participants = await this.em.find(
          ThreadParticipant,
          { thread },
          { populate: ['user'] },
        );
        return {
          ...thread,
          lastMessage,
          participants: participants.map((p) => ({
            userId: p.user.id,
            name: p.user.name,
            avatarUrl: p.user.avatarUrl,
            lastReadAt: p.lastReadAt,
          })),
        };
      }),
    );

    return {
      items,
      nextCursor: hasMore ? threads[threads.length - 1].updatedAt.toISOString() : undefined,
    };
  }

  async getMessages(
    userId: string,
    threadId: string,
    cursor?: string,
    limit = 50,
  ): Promise<{ items: Message[]; nextCursor?: string }> {
    // Verify user is participant
    const participation = await this.em.findOne(ThreadParticipant, {
      thread: threadId,
      user: userId,
    });
    if (!participation) throw new ForbiddenException('Not a participant of this thread');

    const where: Record<string, any> = { thread: threadId };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(Message, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['sender'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
    };
  }

  async sendMessage(user: User, threadId: string, dto: SendMessageDto): Promise<Message> {
    const thread = await this.em.findOne(Thread, { id: threadId });
    if (!thread) throw new NotFoundException('Thread not found');

    const participation = await this.em.findOne(ThreadParticipant, {
      thread,
      user,
    });
    if (!participation) throw new ForbiddenException('Not a participant of this thread');

    const message = this.em.create(Message, {
      thread,
      sender: user,
      text: dto.text,
      mediaId: dto.mediaId,
    } as any);

    thread.updatedAt = new Date();
    await this.em.flush();
    return message;
  }

  async markRead(userId: string, threadId: string): Promise<void> {
    const participation = await this.em.findOne(ThreadParticipant, {
      thread: threadId,
      user: userId,
    });
    if (!participation) throw new ForbiddenException('Not a participant of this thread');

    participation.lastReadAt = new Date();
    await this.em.flush();
  }
}
