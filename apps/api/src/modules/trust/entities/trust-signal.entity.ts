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
 * Append-only trust signal. A user's trust_score = clamp(0, 100, SUM(delta))
 * over active signals (expires_at IS NULL OR > now()). See TRUST_ENGINE §2
 * for the full weight table and IDENTITY_CONTRACT §7 for identity-owned
 * signals.
 *
 * signal_type is free text (not an enum column) so moderation / future
 * subsystems can append rows without a schema change. Identity-subsystem
 * signals use values from `TrustSignalType`.
 */
@Entity({ tableName: 'trust_signals' })
@Index({ properties: ['user'] })
export class TrustSignal {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User, { fieldName: 'user_id' })
  user!: User;

  @Property({ type: 'varchar', length: 64 })
  signalType!: string;

  @Property({ type: 'int' })
  delta!: number;

  @Property({ type: 'varchar', length: 32, nullable: true })
  source?: string;

  @Property({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;

  @Property({ type: 'timestamptz', nullable: true })
  expiresAt?: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
