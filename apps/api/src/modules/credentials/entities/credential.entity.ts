import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  ManyToOne,
  Index,
  Unique,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { CredentialType } from '../../../common/enums';
import { User } from '../../users/entities/user.entity';

/**
 * A verified identity credential attached to a user.
 *
 * One user may own many credentials (phone, email, google, apple). Unique
 * on (type, identifier) globally — the same phone number cannot belong to
 * two users. See IDENTITY_CONTRACT §3.3.
 */
@Entity({ tableName: 'credentials' })
@Unique({ properties: ['type', 'identifier'] })
@Index({ properties: ['user'] })
@Index({ properties: ['type', 'identifier'] })
export class Credential {
  [OptionalProps]?: 'isPrimary' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User, { fieldName: 'user_id' })
  user!: User;

  @Enum({ items: () => CredentialType })
  type!: CredentialType;

  /**
   * Normalised identifier: E.164 phone, lowercased email, or SSO `sub`.
   */
  @Property({ type: 'varchar', length: 320 })
  identifier!: string;

  /**
   * Raw SSO claims for audit. Null for phone / email credentials.
   */
  @Property({ type: 'jsonb', nullable: true })
  providerData?: Record<string, unknown>;

  @Property({ type: 'timestamptz' })
  verifiedAt!: Date;

  @Property({ type: 'boolean', default: false })
  isPrimary: boolean = false;

  @Property({ type: 'timestamptz', nullable: true })
  revokedAt?: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  lastUsedAt?: Date;
}
