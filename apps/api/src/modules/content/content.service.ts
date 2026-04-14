import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Content } from './entities/content.entity';
import { Video } from './entities/video.entity';
import { Post } from './entities/post.entity';
import { Tag } from './entities/tag.entity';
import { ContentTag } from './entities/content-tag.entity';
import { User } from '../users/entities/user.entity';
import { CreateVideoDto } from './dto/create-video.dto';
import { CreatePostDto } from './dto/create-post.dto';
import { ContentStatus, ContentType } from '../../common/enums';

@Injectable()
export class ContentService {
  constructor(private readonly em: EntityManager) {}

  // TODO: creators can now tag interests via POST /content/:id/interest-tags
  // (see ContentInterestTagsService — D3b). A follow-up can accept
  // `interest_ids` directly in CreateVideoDto / CreatePostDto so tagging
  // happens in a single request at upload time.
  async createVideo(user: User, dto: CreateVideoDto): Promise<Video> {
    const video = this.em.create(Video, {
      type: ContentType.VIDEO,
      creator: user,
      videoUrl: dto.videoUrl,
      thumbnailUrl: dto.thumbnailUrl,
      durationSeconds: dto.durationSeconds,
      caption: dto.caption,
      musicId: dto.musicId,
      visibility: dto.visibility,
      status: ContentStatus.ACTIVE,
      location:
        dto.latitude !== undefined && dto.longitude !== undefined
          ? { latitude: dto.latitude, longitude: dto.longitude }
          : undefined,
      locationName: dto.locationName,
    } as any);

    await this.em.flush();
    if (dto.tags?.length) await this.attachTags(video, dto.tags);
    return video;
  }

  async createPost(user: User, dto: CreatePostDto): Promise<Post> {
    const post = this.em.create(Post, {
      type: ContentType.POST,
      creator: user,
      text: dto.text,
      subType: dto.subType,
      isPinned: dto.isPinned,
      visibility: dto.visibility,
      status: ContentStatus.ACTIVE,
      location:
        dto.latitude !== undefined && dto.longitude !== undefined
          ? { latitude: dto.latitude, longitude: dto.longitude }
          : undefined,
      locationName: dto.locationName,
    } as any);

    await this.em.flush();
    if (dto.tags?.length) await this.attachTags(post, dto.tags);
    return post;
  }

  async findById(id: string): Promise<Content> {
    const content = await this.em.findOne(Content, { id }, { populate: ['creator'] });
    if (!content) throw new NotFoundException('Content not found');
    return content;
  }

  async updateStatus(
    id: string,
    status: ContentStatus,
    userId: string,
    isAdmin = false,
  ): Promise<Content> {
    const content = await this.findById(id);

    if (!isAdmin && content.creator.id !== userId) {
      throw new ForbiddenException('Not the content creator');
    }

    // Validate state transitions
    if (!isAdmin) {
      if (status === ContentStatus.HIDDEN && content.status !== ContentStatus.ACTIVE) {
        throw new ForbiddenException('Can only hide active content');
      }
      if (status === ContentStatus.ACTIVE && content.status !== ContentStatus.HIDDEN) {
        throw new ForbiddenException('Can only unhide hidden content');
      }
    }

    content.status = status;
    await this.em.flush();
    return content;
  }

  async softDelete(id: string, userId: string, isAdmin = false): Promise<void> {
    const content = await this.findById(id);
    if (!isAdmin && content.creator.id !== userId) {
      throw new ForbiddenException('Not the content creator');
    }
    content.deletedAt = new Date();
    content.status = ContentStatus.REMOVED;
    await this.em.flush();
  }

  private async attachTags(content: Content, tagNames: string[]): Promise<void> {
    for (const name of tagNames) {
      const normalized = name.toLowerCase().trim().slice(0, 50);
      if (!normalized) continue;

      let tag = await this.em.findOne(Tag, { name: normalized });
      if (!tag) {
        tag = this.em.create(Tag, { name: normalized } as any);
      }
      tag.usageCount++;

      this.em.create(ContentTag, { content, tag } as any);
    }
    await this.em.flush();
  }
}
