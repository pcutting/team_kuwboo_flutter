import {
  Entity,
  PrimaryKey,
  Property,
  OneToOne,
  OptionalProps,
} from '@mikro-orm/core';
import { v4 } from 'uuid';
import { User } from './user.entity';

export interface NotificationPreferences {
  likes: boolean;
  comments: boolean;
  follows: boolean;
  messages: boolean;
  marketing: boolean;
}

export interface PrivacyPreferences {
  showOnlineStatus: boolean;
  showLastActive: boolean;
  showLocation: boolean;
  allowStrangerMessages: boolean;
}

@Entity({ tableName: 'user_preferences' })
export class UserPreferences {
  [OptionalProps]?: 'notifications' | 'privacy' | 'createdAt' | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @OneToOne(() => User, { owner: true, unique: true })
  user!: User;

  @Property({ type: 'jsonb' })
  notifications: NotificationPreferences = {
    likes: true,
    comments: true,
    follows: true,
    messages: true,
    marketing: false,
  };

  @Property({ type: 'jsonb' })
  privacy: PrivacyPreferences = {
    showOnlineStatus: true,
    showLastActive: true,
    showLocation: true,
    allowStrangerMessages: true,
  };

  @Property({ type: 'jsonb', nullable: true })
  feedWeights?: Record<string, number>;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
