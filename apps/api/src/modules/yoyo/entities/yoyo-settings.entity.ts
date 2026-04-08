import {
  Entity,
  PrimaryKey,
  Property,
  OneToOne,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'yoyo_settings' })
export class YoyoSettings {
  [OptionalProps]?: 'isVisible' | 'radiusKm' | 'createdAt' | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @OneToOne(() => User, { owner: true, unique: true })
  user!: User;

  @Property({ type: 'boolean', default: true })
  isVisible: boolean = true;

  @Property({ type: 'int', default: 10 })
  radiusKm: number = 10;

  @Property({ type: 'int', nullable: true })
  ageMin?: number;

  @Property({ type: 'int', nullable: true })
  ageMax?: number;

  @Property({ type: 'varchar', length: 20, nullable: true })
  genderFilter?: string;

  @Property({ type: 'jsonb', nullable: true })
  showInModules?: Record<string, boolean>;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
