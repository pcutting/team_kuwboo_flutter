import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { MikroORM } from '@mikro-orm/core';
import { Job, UnrecoverableError } from 'bullmq';
import { promises as fs } from 'fs';
import { createReadStream, createWriteStream } from 'fs';
import * as os from 'os';
import * as path from 'path';
import { randomUUID } from 'crypto';
import { pipeline } from 'stream/promises';
import sharp from 'sharp';
import ffmpeg from 'fluent-ffmpeg';
import { Media } from '../entities/media.entity';
import { S3Provider } from '../providers/s3.provider';
import { MediaType, MediaStatus } from '../../../common/enums';
import {
  MEDIA_PROCESSING_QUEUE,
  MediaProcessJob,
} from './media-processing.queue';

/**
 * Async media processing worker. Runs after `POST /media/:id/confirm`
 * verifies the original upload on S3.
 *
 * Image branch (sharp):
 *   - Strip EXIF + auto-rotate
 *   - Extract width/height
 *   - 480px wide JPEG thumbnail → s3 media/{mediaId}/thumb.jpg
 *
 * Video branch (fluent-ffmpeg):
 *   - ffprobe for duration + dimensions
 *   - Thumbnail (first keyframe, 480px wide JPEG) → s3 media/{mediaId}/thumb.jpg
 *   - Transcode to 720p H.264 MP4, ~1.5Mbps → s3 media/{mediaId}/720p.mp4
 *
 * On success: sets thumbnailUrl (+ transcodedUrl, duration for video),
 * width/height, status=READY.
 *
 * On terminal failure (after BullMQ retries): sets status=FAILED. We
 * do NOT rethrow from the terminal failure handler or BullMQ spins.
 *
 * NSFW detection + adaptive bitrate streams are M3 — explicitly out of
 * scope for this M2 ship.
 */
@Processor(MEDIA_PROCESSING_QUEUE, { concurrency: 1 })
export class MediaProcessingProcessor extends WorkerHost {
  private readonly logger = new Logger(MediaProcessingProcessor.name);

  constructor(
    private readonly orm: MikroORM,
    private readonly s3: S3Provider,
  ) {
    super();
  }

  async process(job: Job<MediaProcessJob>): Promise<void> {
    const { mediaId } = job.data;
    const em = this.orm.em.fork();
    const tmpDir = await fs.mkdtemp(
      path.join(os.tmpdir(), `media-${mediaId}-${randomUUID()}-`),
    );

    try {
      const media = await em.findOne(Media, { id: mediaId });
      if (!media) {
        this.logger.warn(`Media ${mediaId} not found, skipping`);
        throw new UnrecoverableError(`Media ${mediaId} not found`);
      }

      // Download the original to a temp file.
      const originalExt = path.extname(media.s3Key) || '';
      const originalPath = path.join(tmpDir, `original${originalExt}`);
      await this.downloadOriginal(media.s3Key, originalPath);

      if (media.type === MediaType.IMAGE) {
        await this.processImage(media, originalPath, tmpDir);
      } else if (media.type === MediaType.VIDEO) {
        await this.processVideo(media, originalPath, tmpDir);
      } else {
        // Audio / unknown — mark ready with no derivatives.
        this.logger.log(
          `Media ${mediaId} type=${media.type} — no processing branch, marking READY`,
        );
      }

      media.url = this.s3.getPublicUrl(media.s3Key);
      media.status = MediaStatus.READY;
      await em.flush();

      this.logger.log(`Media ${mediaId} processed successfully`);
    } catch (err) {
      const isLast =
        job.attemptsMade + 1 >= (job.opts.attempts ?? 1) ||
        err instanceof UnrecoverableError;

      this.logger.error(
        `Media ${mediaId} processing error (attempt ${job.attemptsMade + 1}/${job.opts.attempts ?? 1}): ${(err as Error).message}`,
      );

      if (isLast) {
        // Terminal failure — mark FAILED and swallow so BullMQ stops
        // spinning. Best-effort: if the DB write also fails we log but
        // don't rethrow.
        try {
          const media = await em.findOne(Media, { id: mediaId });
          if (media) {
            media.status = MediaStatus.FAILED;
            await em.flush();
          }
        } catch (flushErr) {
          this.logger.error(
            `Failed to mark media ${mediaId} FAILED: ${(flushErr as Error).message}`,
          );
        }
        return;
      }

      // Non-terminal — rethrow so BullMQ retries with the configured
      // exponential backoff.
      throw err;
    } finally {
      await fs
        .rm(tmpDir, { recursive: true, force: true })
        .catch((cleanupErr: unknown) => {
          this.logger.warn(
            `Failed to clean up temp dir ${tmpDir}: ${(cleanupErr as Error).message}`,
          );
        });
    }
  }

  private async downloadOriginal(key: string, destPath: string): Promise<void> {
    const stream = await this.s3.getObjectStream(key);
    await pipeline(stream, createWriteStream(destPath));
  }

  private async processImage(
    media: Media,
    originalPath: string,
    tmpDir: string,
  ): Promise<void> {
    // Strip EXIF + auto-rotate. withMetadata({exif:{}}) ensures no EXIF
    // block survives the re-encode.
    const pipelineInstance = sharp(originalPath)
      .rotate()
      .withMetadata({ exif: {} });

    const metadata = await pipelineInstance.metadata();
    if (metadata.width) media.width = metadata.width;
    if (metadata.height) media.height = metadata.height;

    const thumbPath = path.join(tmpDir, 'thumb.jpg');
    await sharp(originalPath)
      .rotate()
      .withMetadata({ exif: {} })
      .resize(480)
      .jpeg({ quality: 82 })
      .toFile(thumbPath);

    const thumbKey = `media/${media.id}/thumb.jpg`;
    const thumbBuffer = await fs.readFile(thumbPath);
    await this.s3.putObject(thumbKey, thumbBuffer, 'image/jpeg');
    media.thumbnailUrl = this.s3.getPublicUrl(thumbKey);
  }

  private async processVideo(
    media: Media,
    originalPath: string,
    tmpDir: string,
  ): Promise<void> {
    // ffprobe for metadata.
    const probe = await this.probeVideo(originalPath);
    if (probe.durationSeconds !== undefined) {
      media.durationSeconds = Math.round(probe.durationSeconds);
    }
    if (probe.width) media.width = probe.width;
    if (probe.height) media.height = probe.height;

    // Thumbnail — first keyframe, 480px wide JPEG.
    const thumbPath = path.join(tmpDir, 'thumb.jpg');
    await this.extractThumbnail(originalPath, thumbPath);
    const thumbKey = `media/${media.id}/thumb.jpg`;
    const thumbBuffer = await fs.readFile(thumbPath);
    await this.s3.putObject(thumbKey, thumbBuffer, 'image/jpeg');
    media.thumbnailUrl = this.s3.getPublicUrl(thumbKey);

    // Transcode — 720p H.264 MP4, ~1.5 Mbps.
    const transcodedPath = path.join(tmpDir, '720p.mp4');
    await this.transcodeVideo(originalPath, transcodedPath);
    const transcodedKey = `media/${media.id}/720p.mp4`;
    const transcodedStream = createReadStream(transcodedPath);
    await this.s3.putObject(transcodedKey, transcodedStream, 'video/mp4');
    media.transcodedUrl = this.s3.getPublicUrl(transcodedKey);
  }

  private probeVideo(inputPath: string): Promise<{
    durationSeconds?: number;
    width?: number;
    height?: number;
  }> {
    return new Promise((resolve, reject) => {
      ffmpeg.ffprobe(inputPath, (err, data) => {
        if (err) {
          reject(err);
          return;
        }
        const videoStream = data.streams.find((s) => s.codec_type === 'video');
        resolve({
          durationSeconds: data.format?.duration,
          width: videoStream?.width,
          height: videoStream?.height,
        });
      });
    });
  }

  private extractThumbnail(
    inputPath: string,
    outputPath: string,
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .outputOptions([
          '-ss',
          '00:00:01',
          '-frames:v',
          '1',
          '-vf',
          'scale=480:-1',
        ])
        .on('end', () => resolve())
        .on('error', (err: Error) => reject(err))
        .save(outputPath);
    });
  }

  private transcodeVideo(
    inputPath: string,
    outputPath: string,
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .outputOptions([
          '-vf',
          'scale=-2:720',
          '-c:v',
          'libx264',
          '-preset',
          'fast',
          '-b:v',
          '1500k',
          '-maxrate',
          '1800k',
          '-bufsize',
          '3000k',
          '-c:a',
          'aac',
          '-b:a',
          '128k',
          '-movflags',
          '+faststart',
        ])
        .on('end', () => resolve())
        .on('error', (err: Error) => reject(err))
        .save(outputPath);
    });
  }
}

