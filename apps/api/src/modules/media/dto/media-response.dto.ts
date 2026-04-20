import { ApiProperty } from '@nestjs/swagger';
import { Media } from '../entities/media.entity';
import { MediaType, MediaStatus } from '../../../common/enums';

/**
 * Serialized media row for clients. Exposes everything the mobile
 * app needs to render a post card without having to query multiple
 * endpoints: URLs, dimensions, duration, processing status, and
 * the mime type. `url` is the original; `thumbnailUrl` and
 * `transcodedUrl` are derivatives produced by the async worker.
 */
export class MediaResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ enum: MediaStatus })
  status!: MediaStatus;

  @ApiProperty({ enum: MediaType })
  type!: MediaType;

  @ApiProperty()
  mimeType!: string;

  @ApiProperty({ required: false, nullable: true })
  url?: string;

  @ApiProperty({ required: false, nullable: true })
  thumbnailUrl?: string;

  @ApiProperty({ required: false, nullable: true })
  transcodedUrl?: string;

  @ApiProperty({ required: false, nullable: true })
  width?: number;

  @ApiProperty({ required: false, nullable: true })
  height?: number;

  @ApiProperty({ required: false, nullable: true })
  durationSeconds?: number;

  static fromEntity(media: Media): MediaResponseDto {
    const dto = new MediaResponseDto();
    dto.id = media.id;
    dto.status = media.status;
    dto.type = media.type;
    dto.mimeType = media.mimeType;
    dto.url = media.url;
    dto.thumbnailUrl = media.thumbnailUrl;
    dto.transcodedUrl = media.transcodedUrl;
    dto.width = media.width;
    dto.height = media.height;
    dto.durationSeconds = media.durationSeconds;
    return dto;
  }
}
