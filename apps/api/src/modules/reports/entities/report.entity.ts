import { Entity, PrimaryKey, Property, ManyToOne, Enum, Index, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';
import { Comment } from '../../comments/entities/comment.entity';
import { ReportTargetType, ReportReason, ReportStatus } from '../../../common/enums';

@Entity({ tableName: 'reports' })
@Index({ properties: ['status', 'createdAt'] })
export class Report {
  [OptionalProps]?: 'status' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  reporter!: User;

  @Enum({ items: () => ReportTargetType })
  targetType!: ReportTargetType;

  @ManyToOne(() => Content, { nullable: true })
  reportedContent?: Content;

  @ManyToOne(() => User, { nullable: true })
  reportedUser?: User;

  @ManyToOne(() => Comment, { nullable: true })
  reportedComment?: Comment;

  @Enum({ items: () => ReportReason })
  reason!: ReportReason;

  @Property({ type: 'text', nullable: true })
  description?: string;

  @Enum({ items: () => ReportStatus, default: ReportStatus.PENDING })
  status: ReportStatus = ReportStatus.PENDING;

  @Property({ type: 'uuid', nullable: true })
  reviewedBy?: string;

  @Property({ type: 'text', nullable: true })
  reviewNotes?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  reviewedAt?: Date;
}
