import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  OneToOne,
  Filter,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { v4 } from 'uuid';
import { Role, UserStatus, OnlineStatus } from '../../../common/enums';
import { PointType, Point } from '../../../database/types/point.type';
import { UserPreferences } from './user-preferences.entity';

@Entity({ tableName: 'users' })
@Filter({ name: 'notDeleted', cond: { deletedAt: null }, default: true })
@Index({ properties: ['status'] })
export class User {
  [OptionalProps]?:
    | 'role'
    | 'status'
    | 'onlineStatus'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property({ type: 'varchar', length: 20, nullable: true, unique: true })
  phone?: string;

  @Property({ type: 'varchar', length: 255, nullable: true, unique: true })
  email?: string;

  @Property({ type: 'varchar', length: 100 })
  name!: string;

  @Property({ type: 'varchar', length: 512, nullable: true })
  avatarUrl?: string;

  @Property({ type: 'date', nullable: true })
  dateOfBirth?: Date;

  @Enum({ items: () => Role, default: Role.USER })
  role: Role = Role.USER;

  @Enum({ items: () => UserStatus, default: UserStatus.ACTIVE })
  status: UserStatus = UserStatus.ACTIVE;

  @Property({ type: PointType, nullable: true })
  lastLocation?: Point;

  @Enum({ items: () => OnlineStatus, default: OnlineStatus.OFFLINE })
  onlineStatus: OnlineStatus = OnlineStatus.OFFLINE;

  @Property({ type: 'varchar', length: 255, nullable: true, hidden: true })
  passwordHash?: string;

  @Property({ type: 'varchar', length: 255, nullable: true, unique: true })
  googleId?: string;

  @Property({ type: 'varchar', length: 255, nullable: true, unique: true })
  appleId?: string;

  @OneToOne(() => UserPreferences, (prefs) => prefs.user, {
    nullable: true,
    orphanRemoval: true,
  })
  preferences?: UserPreferences;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  deletedAt?: Date;
}
