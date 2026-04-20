import { Job } from 'bullmq';
import { promises as fs } from 'fs';
import { Readable } from 'stream';
import { MikroORM } from '@mikro-orm/core';
import { MediaProcessingProcessor } from './media-processing.processor';
import { MediaProcessJob } from './media-processing.queue';
import { S3Provider } from '../providers/s3.provider';
import { Media } from '../entities/media.entity';
import { MediaType, MediaStatus } from '../../../common/enums';

// --- Mock sharp ---------------------------------------------------------
// sharp is a native binding; we don't want to touch it in CI. The mock
// returns a chainable fluent API plus a fake metadata/toFile.
jest.mock('sharp', () => {
  const chain = () => {
    const api: {
      rotate: () => typeof api;
      withMetadata: () => typeof api;
      resize: () => typeof api;
      jpeg: () => typeof api;
      metadata: () => Promise<{ width: number; height: number }>;
      toFile: (out: string) => Promise<void>;
    } = {
      rotate: () => api,
      withMetadata: () => api,
      resize: () => api,
      jpeg: () => api,
      metadata: () => Promise.resolve({ width: 1200, height: 800 }),
      toFile: async (out: string) => {
        await fs.writeFile(out, Buffer.from('fake-jpeg-bytes'));
      },
    };
    return api;
  };
  const sharpFn = jest.fn(() => chain());
  return { __esModule: true, default: sharpFn };
});

// --- Mock fluent-ffmpeg -------------------------------------------------
// fluent-ffmpeg shells out to the ffmpeg binary. We mock the builder
// to invoke the 'end' handler synchronously and write a placeholder
// output file so the downstream upload path is exercised.
jest.mock('fluent-ffmpeg', () => {
  type Handler = () => void;
  type ErrHandler = (err: Error) => void;
  type Builder = {
    outputOptions: () => Builder;
    on: (event: string, cb: Handler | ErrHandler) => Builder;
    save: (out: string) => Builder;
  };

  const builder = (): Builder => {
    let endCb: Handler | null = null;
    const b: Builder = {
      outputOptions: () => b,
      on: (event, cb) => {
        if (event === 'end') endCb = cb as Handler;
        return b;
      },
      save: (out: string) => {
        // Write a placeholder so fs.readFile / createReadStream works.
        fs.writeFile(out, Buffer.from('fake-media-bytes')).then(() => {
          if (endCb) endCb();
        });
        return b;
      },
    };
    return b;
  };

  const ffmpegFn = jest.fn(() => builder()) as jest.Mock & {
    ffprobe: jest.Mock;
  };
  ffmpegFn.ffprobe = jest.fn(
    (
      _input: string,
      cb: (
        err: Error | null,
        data: {
          format: { duration: number };
          streams: Array<{
            codec_type: string;
            width?: number;
            height?: number;
          }>;
        },
      ) => void,
    ) => {
      cb(null, {
        format: { duration: 12.5 },
        streams: [{ codec_type: 'video', width: 1920, height: 1080 }],
      });
    },
  );

  return { __esModule: true, default: ffmpegFn };
});

interface FakeEm {
  findOne: jest.Mock;
  flush: jest.Mock;
  fork: jest.Mock;
}

describe('MediaProcessingProcessor', () => {
  let processor: MediaProcessingProcessor;
  let em: FakeEm;
  let s3: jest.Mocked<Pick<S3Provider, 'putObject' | 'getObjectStream' | 'getPublicUrl'>>;
  let media: Media;

  function makeMedia(overrides: Partial<Media> = {}): Media {
    const m = new Media();
    m.id = 'media-1';
    m.type = MediaType.IMAGE;
    m.mimeType = 'image/jpeg';
    m.sizeBytes = 1024;
    m.s3Key = 'media/user-1/uuid-1/photo.jpg';
    m.s3Bucket = 'kuwboo-media-dev';
    m.status = MediaStatus.PROCESSING;
    Object.assign(m, overrides);
    return m;
  }

  function makeJob(
    data: MediaProcessJob = { mediaId: 'media-1' },
    attemptsMade = 0,
    attempts = 3,
  ): Job<MediaProcessJob> {
    return {
      name: 'process',
      data,
      attemptsMade,
      opts: { attempts },
    } as unknown as Job<MediaProcessJob>;
  }

  function makeStream(): Readable {
    const s = new Readable();
    s._read = () => {
      s.push(Buffer.from('fake-original-bytes'));
      s.push(null);
    };
    return s;
  }

  beforeEach(() => {
    media = makeMedia();
    em = {
      findOne: jest.fn().mockResolvedValue(media),
      flush: jest.fn().mockResolvedValue(undefined),
      fork: jest.fn(),
    };
    em.fork.mockReturnValue(em);

    const orm = { em } as unknown as MikroORM;

    s3 = {
      putObject: jest.fn().mockResolvedValue(undefined),
      getObjectStream: jest.fn().mockImplementation(async () => makeStream()),
      getPublicUrl: jest
        .fn()
        .mockImplementation((key: string) => `https://cdn.example.com/${key}`),
    };

    processor = new MediaProcessingProcessor(orm, s3 as unknown as S3Provider);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('processes an image: strips EXIF, extracts dimensions, uploads thumb, marks READY', async () => {
    media = makeMedia({ type: MediaType.IMAGE });
    em.findOne.mockResolvedValue(media);

    await processor.process(makeJob());

    expect(media.status).toBe(MediaStatus.READY);
    expect(media.width).toBe(1200);
    expect(media.height).toBe(800);
    expect(media.thumbnailUrl).toBe(
      'https://cdn.example.com/media/media-1/thumb.jpg',
    );
    // Image branch uploads only the thumb.
    expect(s3.putObject).toHaveBeenCalledTimes(1);
    expect(s3.putObject).toHaveBeenCalledWith(
      'media/media-1/thumb.jpg',
      expect.any(Buffer),
      'image/jpeg',
    );
    expect(em.flush).toHaveBeenCalled();
  });

  it('processes a video: probes, extracts thumb, transcodes to 720p, marks READY', async () => {
    media = makeMedia({
      type: MediaType.VIDEO,
      mimeType: 'video/mp4',
      s3Key: 'media/user-1/uuid-2/clip.mp4',
    });
    em.findOne.mockResolvedValue(media);

    await processor.process(makeJob());

    expect(media.status).toBe(MediaStatus.READY);
    expect(media.width).toBe(1920);
    expect(media.height).toBe(1080);
    expect(media.durationSeconds).toBe(13); // rounded from 12.5
    expect(media.thumbnailUrl).toBe(
      'https://cdn.example.com/media/media-1/thumb.jpg',
    );
    expect(media.transcodedUrl).toBe(
      'https://cdn.example.com/media/media-1/720p.mp4',
    );
    // Video branch uploads thumb + transcoded.
    expect(s3.putObject).toHaveBeenCalledWith(
      'media/media-1/thumb.jpg',
      expect.any(Buffer),
      'image/jpeg',
    );
    expect(s3.putObject).toHaveBeenCalledWith(
      'media/media-1/720p.mp4',
      expect.anything(),
      'video/mp4',
    );
    expect(em.flush).toHaveBeenCalled();
  });

  it('marks media FAILED on terminal failure (last attempt)', async () => {
    media = makeMedia({ type: MediaType.IMAGE });
    em.findOne.mockResolvedValue(media);
    s3.putObject.mockRejectedValueOnce(new Error('boom'));

    // Last attempt: attemptsMade=2, attempts=3 → 2+1 >= 3 → terminal.
    await expect(processor.process(makeJob({ mediaId: 'media-1' }, 2, 3))).resolves.toBeUndefined();

    expect(media.status).toBe(MediaStatus.FAILED);
    expect(em.flush).toHaveBeenCalled();
  });

  it('rethrows on non-terminal failure so BullMQ retries', async () => {
    media = makeMedia({ type: MediaType.IMAGE });
    em.findOne.mockResolvedValue(media);
    s3.putObject.mockRejectedValueOnce(new Error('transient'));

    // attemptsMade=0, attempts=3 → 0+1 < 3 → should rethrow.
    await expect(processor.process(makeJob({ mediaId: 'media-1' }, 0, 3))).rejects.toThrow('transient');
    // Status NOT flipped to FAILED on non-terminal.
    expect(media.status).toBe(MediaStatus.PROCESSING);
  });

  it('cleans up temp files even when processing fails', async () => {
    media = makeMedia({ type: MediaType.IMAGE });
    em.findOne.mockResolvedValue(media);
    s3.putObject.mockRejectedValueOnce(new Error('boom'));

    const rmSpy = jest.spyOn(fs, 'rm');

    await expect(
      processor.process(makeJob({ mediaId: 'media-1' }, 2, 3)),
    ).resolves.toBeUndefined();

    expect(rmSpy).toHaveBeenCalledWith(
      expect.stringContaining('media-media-1-'),
      { recursive: true, force: true },
    );

    rmSpy.mockRestore();
  });

  it('marks FAILED unrecoverably when media row is missing', async () => {
    em.findOne.mockResolvedValueOnce(null); // first lookup: gone
    em.findOne.mockResolvedValueOnce(null); // terminal-failure lookup: still gone
    // Terminal attempt so the UnrecoverableError branch lands in FAILED.
    await expect(
      processor.process(makeJob({ mediaId: 'ghost' }, 2, 3)),
    ).resolves.toBeUndefined();
  });
});
