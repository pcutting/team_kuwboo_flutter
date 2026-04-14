import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { Content } from './content.entity';
import { Interest } from '../../interests/entities/interest.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Join table mapping Content to Interests for behavioural signal routing.
 *
 * - Composite primary key on (content, interest).
 * - `assignedByUserId` is null when the tag was applied automatically
 *   (future auto-classifier) and non-null for creator/admin-assigned tags.
 * - `confidence` allows future ML-classified tags to carry a score
 *   (defaults to 1.0 for explicit human tags).
 */
@Entity({ tableName: 'content_interest_tags' })
@Index({ name: 'content_interest_tags_content_id_index', properties: ['content'] })
@Index({ name: 'content_interest_tags_interest_id_index', properties: ['interest'] })
export class ContentInterestTag {
  [OptionalProps]?: 'assignedAt' | 'confidence';

  @ManyToOne(() => Content, { primary: true, deleteRule: 'cascade' })
  content!: Content;

  @ManyToOne(() => Interest, { primary: true, deleteRule: 'cascade' })
  interest!: Interest;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  assignedAt: Date = new Date();

  @ManyToOne(() => User, { nullable: true, fieldName: 'assigned_by_user_id' })
  assignedByUser?: User;

  @Property({ type: 'float', default: 1.0 })
  confidence: number = 1.0;
}
