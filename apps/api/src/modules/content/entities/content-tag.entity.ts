import { Entity, PrimaryKey, ManyToOne, Unique, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { Content } from './content.entity';
import { Tag } from './tag.entity';

@Entity({ tableName: 'content_tags' })
@Unique({ properties: ['content', 'tag'] })
export class ContentTag {
  [OptionalProps]?: never;

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => Content)
  content!: Content;

  @ManyToOne(() => Tag)
  tag!: Tag;
}
