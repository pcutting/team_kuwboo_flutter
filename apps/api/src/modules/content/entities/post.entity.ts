import { Entity, Property, Enum } from '@mikro-orm/core';
import { Content } from './content.entity';
import { PostSubType } from '../../../common/enums';

@Entity({ discriminatorValue: 'POST' })
export class Post extends Content {
  @Enum({ items: () => PostSubType, default: PostSubType.STANDARD })
  subType: PostSubType = PostSubType.STANDARD;

  @Property({ type: 'text' })
  text!: string;

  @Property({ type: 'boolean', default: false })
  isPinned: boolean = false;

  @Property({ type: 'varchar', length: 50, nullable: true })
  readingTime?: string;
}
