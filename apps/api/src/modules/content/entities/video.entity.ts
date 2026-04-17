import { Entity, Property } from '@mikro-orm/core';
import { Content } from './content.entity';

@Entity({ discriminatorValue: 'VIDEO' })
export class Video extends Content {
  @Property({ type: 'varchar', length: 1024 })
  videoUrl!: string;

  // `thumbnailUrl` is declared on Content (nullable) so it can be used
  // across all STI subtypes. Videos, however, always have a poster
  // frame — we narrow the type here to non-nullable. The column
  // definition remains that of the base class.
  declare thumbnailUrl: string;

  @Property({ type: 'int' })
  durationSeconds!: number;

  @Property({ type: 'text', nullable: true })
  caption?: string;

  @Property({ type: 'uuid', nullable: true })
  musicId?: string;
}
