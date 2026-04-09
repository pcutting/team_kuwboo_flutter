import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';

/**
 * Auth provider that originated a session. Sessions are also created for
 * email/password once that flow lands, hence the open enum rather than a
 * strict union at the DB level.
 */
export type SessionProvider = 'phone' | 'google' | 'apple' | 'email';

@Entity({ tableName: 'sessions' })
@Index({ properties: ['provider', 'providerIdentifier'] })
export class Session {
  [OptionalProps]?: 'isRevoked' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  user!: User;

  @Property({ type: 'varchar', length: 255, hidden: true })
  refreshTokenHash!: string;

  @Property({ type: 'varchar', length: 255, nullable: true })
  userAgent?: string;

  @Property({ type: 'varchar', length: 45, nullable: true })
  ipAddress?: string;

  @Property({ type: 'timestamptz' })
  expiresAt!: Date;

  @Property({ type: 'boolean', default: false })
  isRevoked: boolean = false;

  /**
   * Which auth provider created this session. Populated on new sessions;
   * NULL for pre-migration rows which is acceptable — revocation logic
   * ignores provider when not present.
   */
  @Property({ type: 'varchar', length: 20, nullable: true })
  provider?: SessionProvider;

  /**
   * Provider-specific stable user identifier (Apple `sub`, Google `sub`,
   * or phone E.164). Lets the Apple webhook handler find "all sessions
   * for this Apple user" without joining through users.
   */
  @Property({ type: 'varchar', length: 255, nullable: true })
  providerIdentifier?: string;

  /**
   * Free-text reason written when the session was revoked, e.g.
   * 'apple_consent_revoked', 'apple_account_delete', 'token_reuse',
   * 'manual_logout'. Populated only on revocation.
   */
  @Property({ type: 'varchar', length: 100, nullable: true })
  revokeReason?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
