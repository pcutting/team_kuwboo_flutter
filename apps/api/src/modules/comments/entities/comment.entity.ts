import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  OneToMany,
  Collection,
  Index,
  Filter,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';

@Entity({ tableName: 'comments' })
@Filter({ name: 'notDeleted', cond: { deletedAt: null }, default: true })
@Index({ properties: ['content', 'createdAt'] })
export class Comment {
  [OptionalProps]?: 'likeCount' | 'replyCount' | 'createdAt' | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => Content)
  content!: Content;

  @ManyToOne(() => User)
  author!: User;

  @Property({ type: 'text' })
  text!: string;

  @Property({ type: 'int', default: 0 })
  likeCount: number = 0;

  @Property({ type: 'int', default: 0 })
  replyCount: number = 0;

  @ManyToOne(() => Comment, { nullable: true })
  parentComment?: Comment;

  @OneToMany(() => Comment, (c) => c.parentComment)
  replies = new Collection<Comment>(this);

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  deletedAt?: Date;
}
