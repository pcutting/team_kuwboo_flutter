import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { randomUUID } from 'crypto';
import { Media } from './entities/media.entity';
import { S3Provider } from './providers/s3.provider';
import { PresignedUrlRequestDto, PresignedUrlResponseDto } from './dto/presigned-url.dto';
import { User } from '../users/entities/user.entity';
import { MediaType, MediaStatus } from '../../common/enums';
import {
  MEDIA_PROCESSING_QUEUE,
  MediaProcessJob,
} from './workers/media-processing.queue';

const SIZE_LIMITS: Record<MediaType, number> = {
  [MediaType.IMAGE]: 10 * 1024 * 1024, // 10MB
  [MediaType.VIDEO]: 100 * 1024 * 1024, // 100MB
  [MediaType.AUDIO]: 20 * 1024 * 1024, // 20MB
};

const ALLOWED_CONTENT_TYPES: Record<MediaType, string[]> = {
  [MediaType.IMAGE]: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
  [MediaType.VIDEO]: ['video/mp4', 'video/quicktime', 'video/webm'],
  [MediaType.AUDIO]: ['audio/mpeg', 'audio/aac', 'audio/wav', 'audio/m4a'],
};

@Injectable()
export class MediaService {
  constructor(
    private readonly em: EntityManager,
    private readonly s3: S3Provider,
    @InjectQueue(MEDIA_PROCESSING_QUEUE)
    private readonly queue: Queue<MediaProcessJob>,
  ) {}

  async generatePresignedUrl(
    user: User,
    dto: PresignedUrlRequestDto,
  ): Promise<PresignedUrlResponseDto> {
    // Validate content type
    const allowed = ALLOWED_CONTENT_TYPES[dto.type];
    if (!allowed.includes(dto.contentType)) {
      throw new BadRequestException(`Content type ${dto.contentType} not allowed for ${dto.type}`);
    }

    // Validate size
    const maxSize = SIZE_LIMITS[dto.type];
    if (dto.sizeBytes > maxSize) {
      throw new BadRequestException(
        `File too large. Max ${Math.round(maxSize / 1024 / 1024)}MB for ${dto.type}`,
      );
    }

    const s3Key = `media/${user.id}/${randomUUID()}/${dto.fileName}`;
    const uploadUrl = await this.s3.generatePresignedPutUrl(s3Key, dto.contentType);

    const media = this.em.create(Media, {
      uploader: user,
      type: dto.type,
      mimeType: dto.contentType,
      sizeBytes: dto.sizeBytes,
      s3Key,
      s3Bucket: this.s3.bucketName,
    } as any);

    await this.em.flush();

    return { uploadUrl, mediaId: media.id, s3Key };
  }

  async confirmUpload(mediaId: string, userId: string): Promise<Media> {
    const media = await this.em.findOne(Media, { id: mediaId, uploader: { id: userId } });
    if (!media) throw new NotFoundException('Media not found');

    if (media.status !== MediaStatus.PROCESSING) {
      throw new BadRequestException('Media already processed');
    }

    const exists = await this.s3.objectExists(media.s3Key);
    if (!exists) {
      throw new BadRequestException('File not uploaded to S3');
    }

    // Hand off to the async processing worker. Status stays
    // PROCESSING until the worker succeeds (→ READY) or exhausts
    // retries (→ FAILED). The worker also populates thumbnailUrl,
    // transcodedUrl (video), dimensions, and duration.
    await this.queue.add(
      'process',
      { mediaId: media.id },
      {
        attempts: 3,
        backoff: { type: 'exponential', delay: 5000 },
      },
    );

    return media;
  }

  async findById(id: string): Promise<Media> {
    const media = await this.em.findOne(Media, { id });
    if (!media) throw new NotFoundException('Media not found');
    return media;
  }
}
