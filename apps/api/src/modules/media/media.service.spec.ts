import { BadRequestException, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Queue } from 'bullmq';
import { MediaService } from './media.service';
import { S3Provider } from './providers/s3.provider';
import { Media } from './entities/media.entity';
import { MediaType, MediaStatus } from '../../common/enums';
import { MediaProcessJob } from './workers/media-processing.queue';
import { User } from '../users/entities/user.entity';

describe('MediaService.confirmUpload', () => {
  let service: MediaService;
  let em: jest.Mocked<Pick<EntityManager, 'findOne' | 'flush' | 'create'>>;
  let s3: jest.Mocked<Pick<S3Provider, 'objectExists' | 'getPublicUrl' | 'generatePresignedPutUrl' | 'bucketName'>>;
  let queue: jest.Mocked<Pick<Queue<MediaProcessJob>, 'add'>>;

  const userId = 'user-1';
  const mediaId = 'media-1';

  beforeEach(() => {
    em = {
      findOne: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
      create: jest.fn(),
    };
    s3 = {
      objectExists: jest.fn().mockResolvedValue(true),
      getPublicUrl: jest
        .fn()
        .mockImplementation((key: string) => `https://cdn.example.com/${key}`),
      generatePresignedPutUrl: jest
        .fn()
        .mockResolvedValue('https://presigned.example/upload'),
      bucketName: 'kuwboo-media-dev',
    };
    queue = {
      add: jest.fn().mockResolvedValue({ id: 'job-1' }),
    };

    service = new MediaService(
      em as unknown as EntityManager,
      s3 as unknown as S3Provider,
      queue as unknown as Queue<MediaProcessJob>,
    );
  });

  function makeMedia(overrides: Partial<Media> = {}): Media {
    const m = new Media();
    m.id = mediaId;
    m.type = MediaType.VIDEO;
    m.mimeType = 'video/mp4';
    m.sizeBytes = 2048;
    m.s3Key = `media/${userId}/uuid-1/clip.mp4`;
    m.s3Bucket = 'kuwboo-media-dev';
    m.status = MediaStatus.PROCESSING;
    Object.assign(m, overrides);
    return m;
  }

  it('enqueues a media-processing job with retry config on confirm', async () => {
    const media = makeMedia();
    em.findOne.mockResolvedValue(media);

    const result = await service.confirmUpload(mediaId, userId);

    expect(queue.add).toHaveBeenCalledTimes(1);
    expect(queue.add).toHaveBeenCalledWith(
      'process',
      { mediaId: media.id },
      {
        attempts: 3,
        backoff: { type: 'exponential', delay: 5000 },
      },
    );
    // Confirm MUST NOT mark READY — the worker owns that transition.
    expect(result.status).toBe(MediaStatus.PROCESSING);
  });

  it('throws NotFound when the media row is missing', async () => {
    em.findOne.mockResolvedValue(null);
    await expect(service.confirmUpload(mediaId, userId)).rejects.toBeInstanceOf(
      NotFoundException,
    );
    expect(queue.add).not.toHaveBeenCalled();
  });

  it('throws BadRequest when media is already processed', async () => {
    em.findOne.mockResolvedValue(makeMedia({ status: MediaStatus.READY }));
    await expect(service.confirmUpload(mediaId, userId)).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(queue.add).not.toHaveBeenCalled();
  });

  it('throws BadRequest when the S3 object is missing', async () => {
    em.findOne.mockResolvedValue(makeMedia());
    s3.objectExists.mockResolvedValueOnce(false);
    await expect(service.confirmUpload(mediaId, userId)).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(queue.add).not.toHaveBeenCalled();
  });
});

describe('MediaService.generatePresignedUrl', () => {
  let service: MediaService;
  let em: jest.Mocked<Pick<EntityManager, 'findOne' | 'flush' | 'create'>>;
  let s3: jest.Mocked<Pick<S3Provider, 'objectExists' | 'getPublicUrl' | 'generatePresignedPutUrl' | 'bucketName'>>;
  let queue: jest.Mocked<Pick<Queue<MediaProcessJob>, 'add'>>;

  beforeEach(() => {
    em = {
      findOne: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
      create: jest.fn().mockImplementation((_cls, data) => {
        const m = new Media();
        m.id = 'generated-id';
        Object.assign(m, data);
        return m;
      }),
    };
    s3 = {
      objectExists: jest.fn().mockResolvedValue(true),
      getPublicUrl: jest.fn(),
      generatePresignedPutUrl: jest
        .fn()
        .mockResolvedValue('https://presigned.example/upload'),
      bucketName: 'kuwboo-media-dev',
    };
    queue = { add: jest.fn() };

    service = new MediaService(
      em as unknown as EntityManager,
      s3 as unknown as S3Provider,
      queue as unknown as Queue<MediaProcessJob>,
    );
  });

  it('rejects disallowed content types', async () => {
    const user = { id: 'user-1' } as User;
    await expect(
      service.generatePresignedUrl(user, {
        fileName: 'nope.exe',
        contentType: 'application/x-msdownload',
        type: MediaType.IMAGE,
        sizeBytes: 1024,
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('returns presigned URL + media id for a valid request', async () => {
    const user = { id: 'user-1' } as User;
    const res = await service.generatePresignedUrl(user, {
      fileName: 'photo.jpg',
      contentType: 'image/jpeg',
      type: MediaType.IMAGE,
      sizeBytes: 1024,
    });

    expect(res.uploadUrl).toBe('https://presigned.example/upload');
    expect(res.mediaId).toBe('generated-id');
    expect(res.s3Key).toMatch(/^media\/user-1\/.+\/photo\.jpg$/);
    expect(em.flush).toHaveBeenCalled();
  });
});
