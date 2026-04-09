import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Enum,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../../users/entities/user.entity';

/**
 * The four event types Apple delivers via Server-to-Server notifications.
 *
 * - account-delete: user deleted their Apple ID entirely. Soft-delete
 *   the corresponding Kuwboo account per GDPR Article 17 erasure flow.
 * - consent-revoked: user toggled off "Use with Apple ID" for Kuwboo.
 *   Revoke sessions but keep the account (they can re-auth with phone /
 *   Google / email).
 * - email-disabled: user disabled private-relay forwarding. Messages to
 *   that address now bounce. Flag the user.
 * - email-enabled: user re-enabled private-relay forwarding. Clear flag.
 *
 * Values are string literals so they match Apple's payload verbatim.
 */
export enum AppleNotificationType {
  ACCOUNT_DELETE = 'account-delete',
  CONSENT_REVOKED = 'consent-revoked',
  EMAIL_DISABLED = 'email-disabled',
  EMAIL_ENABLED = 'email-enabled',
}

/**
 * One row per Apple Server-to-Server notification we receive.
 *
 * The row is written by the webhook ingest pipeline BEFORE async
 * processing runs, so every signed payload is durable even if the
 * worker crashes. Processing status is tracked by:
 *   - processedAt: NULL until the handler finishes successfully
 *   - processingError: last exception message if processing failed
 *   - processingAttempts: incremented on each failed attempt
 *
 * Idempotency is enforced at the DB level by the jti UNIQUE constraint:
 * an "INSERT ON CONFLICT (jti) DO NOTHING" is used by the ingest service
 * so duplicate deliveries from Apple are a no-op.
 *
 * user is nullable because:
 *   1. Apple may send an event for an apple_sub we no longer recognize
 *      (already hard-deleted).
 *   2. The webhook persists the event BEFORE resolving the user — the
 *      link is filled in by the handler, so rows are briefly NULL.
 *
 * rawPayloadSha256 is kept so we can prove later that a logged event
 * matches what Apple actually sent (non-repudiation trail).
 */
@Entity({ tableName: 'apple_notification_events' })
@Index({ properties: ['eventType', 'processedAt'] })
@Index({ properties: ['appleSub'] })
@Index({ properties: ['user'] })
@Index({ properties: ['appleEventTime'] })
export class AppleNotificationEvent {
  [OptionalProps]?:
    | 'signatureValid'
    | 'processingAttempts'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  /**
   * Apple's JWT ID claim on the S2S notification. Unique across all
   * events — used as the idempotency key for duplicate delivery.
   */
  @Property({ type: 'varchar', length: 64, unique: true })
  jti!: string;

  @Enum({ items: () => AppleNotificationType })
  eventType!: AppleNotificationType;

  /**
   * Apple's stable per-user-per-team identifier, from events.sub.
   * Matches User.appleId when the user exists.
   */
  @Property({ type: 'varchar', length: 255 })
  appleSub!: string;

  /**
   * Timestamp from Apple's events.event_time field (converted from the
   * epoch millis Apple sends to a Date). Used to detect out-of-order
   * deliveries and to power the admin timeline view.
   */
  @Property({ type: 'timestamptz' })
  appleEventTime!: Date;

  /**
   * Link to the Kuwboo user resolved from appleSub. NULL when the
   * webhook event arrives for a sub we no longer track (hard-deleted
   * user) or transiently before the handler resolves the link.
   */
  @ManyToOne(() => User, { nullable: true })
  user?: User;

  @Property({ type: 'boolean', default: true })
  signatureValid: boolean = true;

  /**
   * SHA-256 of the raw POST body as received, before any parsing. Lets
   * us prove the event we logged is byte-for-byte what Apple sent if
   * we ever need to contest a dispute.
   */
  @Property({ type: 'varchar', length: 64 })
  rawPayloadSha256!: string;

  /**
   * The full decoded JWT claims object (iss, aud, exp, iat, jti, sub,
   * events, ...). Kept for audit and admin diagnostics.
   */
  @Property({ type: 'jsonb' })
  claims!: Record<string, any>;

  /**
   * The parsed events object (after JSON.parse'ing the events string
   * claim). Example: { type: 'consent-revoked', sub: '...',
   * event_time: 1712600000000, email: '...', is_private_email: 'true' }
   */
  @Property({ type: 'jsonb' })
  eventPayload!: Record<string, any>;

  @Property({ type: 'varchar', length: 45, nullable: true })
  sourceIp?: string;

  @Property({ type: 'varchar', length: 255, nullable: true })
  userAgent?: string;

  @Property({ type: 'timestamptz', nullable: true })
  processedAt?: Date;

  @Property({ type: 'text', nullable: true })
  processingError?: string;

  @Property({ type: 'int', default: 0 })
  processingAttempts: number = 0;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
