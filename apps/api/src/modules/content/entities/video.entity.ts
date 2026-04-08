import { Entity, Property } from '@mikro-orm/core';
import { Content } from './content.entity';

@Entity({ discriminatorValue: 'VIDEO' })
export class Video extends Content {
  @Property({ type: 'varchar', length: 1024 })
  videoUrl!: string;

  @Property({ type: 'varchar', length: 1024 })
  thumbnailUrl!: string;

  @Property({ type: 'int' })
  durationSeconds!: number;

  @Property({ type: 'text', nullable: true })
  caption?: string;

  @Property({ type: 'uuid', nullable: true })
  musicId?: string;
}
