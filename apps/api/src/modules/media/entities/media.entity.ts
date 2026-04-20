import { Entity, PrimaryKey, Property, ManyToOne, Enum, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { MediaType, MediaStatus } from '../../../common/enums';

@Entity({ tableName: 'media' })
export class Media {
  [OptionalProps]?: 'status' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  uploader!: User;

  @Property({ type: 'varchar', length: 1024, nullable: true })
  url?: string;

  @Property({ type: 'varchar', length: 1024, nullable: true })
  thumbnailUrl?: string;

  @Property({ type: 'varchar', length: 1024, nullable: true })
  transcodedUrl?: string;

  @Enum({ items: () => MediaType })
  type!: MediaType;

  @Enum({ items: () => MediaStatus, default: MediaStatus.PROCESSING })
  status: MediaStatus = MediaStatus.PROCESSING;

  @Property({ type: 'varchar', length: 100 })
  mimeType!: string;

  @Property({ type: 'bigint' })
  sizeBytes!: number;

  @Property({ type: 'int', nullable: true })
  durationSeconds?: number;

  @Property({ type: 'int', nullable: true })
  width?: number;

  @Property({ type: 'int', nullable: true })
  height?: number;

  @Property({ type: 'varchar', length: 1024 })
  s3Key!: string;

  @Property({ type: 'varchar', length: 255 })
  s3Bucket!: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
