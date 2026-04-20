import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  HeadObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Readable } from 'stream';

@Injectable()
export class S3Provider {
  private readonly client: S3Client;
  private readonly bucket: string;

  constructor(private readonly config: ConfigService) {
    this.client = new S3Client({
      region: this.config.get<string>('AWS_REGION') || 'eu-west-2',
    });
    this.bucket = this.config.get<string>('AWS_S3_BUCKET') || 'kuwboo-media-dev';
  }

  get bucketName(): string {
    return this.bucket;
  }

  async generatePresignedPutUrl(
    key: string,
    contentType: string,
    expiresIn = 900,
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      ContentType: contentType,
    });
    return getSignedUrl(this.client, command, { expiresIn });
  }

  async objectExists(key: string): Promise<boolean> {
    try {
      await this.client.send(
        new HeadObjectCommand({ Bucket: this.bucket, Key: key }),
      );
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Upload a derivative asset (thumbnail, transcode, etc.) to S3.
   * Used by the media processing worker after it generates artifacts
   * from the original upload. Swallows nothing — callers must surface
   * failures so BullMQ retry logic fires.
   */
  async putObject(
    key: string,
    body: Buffer | Readable,
    contentType: string,
  ): Promise<void> {
    try {
      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: body,
          ContentType: contentType,
        }),
      );
    } catch (err) {
      throw new InternalServerErrorException(
        `S3 putObject failed for ${key}: ${(err as Error).message}`,
      );
    }
  }

  /**
   * Fetch an S3 object as a Node.js Readable. Used by the media
   * processing worker to stream originals into ffmpeg/sharp without
   * buffering the full object in memory.
   */
  async getObjectStream(key: string): Promise<Readable> {
    try {
      const response = await this.client.send(
        new GetObjectCommand({ Bucket: this.bucket, Key: key }),
      );
      if (!response.Body) {
        throw new Error('S3 response missing Body');
      }
      return response.Body as Readable;
    } catch (err) {
      throw new InternalServerErrorException(
        `S3 getObject failed for ${key}: ${(err as Error).message}`,
      );
    }
  }

  getPublicUrl(key: string): string {
    const cdnDomain = this.config.get<string>('AWS_CLOUDFRONT_DOMAIN');
    if (cdnDomain) {
      return `https://${cdnDomain}/${key}`;
    }
    return `https://${this.bucket}.s3.eu-west-2.amazonaws.com/${key}`;
  }
}
