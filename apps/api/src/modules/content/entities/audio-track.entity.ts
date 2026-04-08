import { Entity, PrimaryKey, Property, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';

@Entity({ tableName: 'audio_tracks' })
export class AudioTrack {
  [OptionalProps]?: 'usageCount' | 'isOriginal' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Property({ type: 'varchar', length: 255 })
  title!: string;

  @Property({ type: 'varchar', length: 255 })
  artistName!: string;

  @Property({ type: 'varchar', length: 1024 })
  url!: string;

  @Property({ type: 'int' })
  durationSeconds!: number;

  @Property({ type: 'int', default: 0 })
  usageCount: number = 0;

  @Property({ type: 'boolean', default: false })
  isOriginal: boolean = false;

  @Property({ type: 'uuid', nullable: true })
  sourceVideoId?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
