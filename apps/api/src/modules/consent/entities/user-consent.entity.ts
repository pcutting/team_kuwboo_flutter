import { Entity, PrimaryKey, Property, ManyToOne, Enum, Unique, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { ConsentType, ConsentSource } from '../../../common/enums';

@Entity({ tableName: 'user_consents' })
@Unique({ properties: ['user', 'consentType', 'version'] })
export class UserConsent {
  [OptionalProps]?: 'grantedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  /**
   * Nullable so the GDPR consent audit trail survives a hard-purge of
   * the grantor's user row (Migration20260420_account_deletion_fk_nullability
   * widens the FK to ON DELETE SET NULL). Still non-optional in
   * practice — every new consent row is written with a live user — but
   * the type must reflect the DB shape.
   */
  @ManyToOne(() => User, { nullable: true })
  user?: User;

  @Enum({ items: () => ConsentType })
  consentType!: ConsentType;

  @Property({ type: 'varchar', length: 20 })
  version!: string;

  @Enum({ items: () => ConsentSource })
  source!: ConsentSource;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  grantedAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  revokedAt?: Date;

  @Property({ type: 'varchar', length: 45, nullable: true })
  ipAddress?: string;

  /**
   * Captured at grant time for audit. Optional — older rows (predating
   * the 2026-04-19 migration) have null. 512 chars is well above the
   * practical UA header length; we truncate aggressively if needed
   * rather than risk DB errors.
   */
  @Property({ type: 'varchar', length: 512, nullable: true })
  userAgent?: string;
}
