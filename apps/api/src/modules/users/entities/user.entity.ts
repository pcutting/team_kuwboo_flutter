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
import { randomUUID } from 'crypto';
import {
  Role,
  UserStatus,
  OnlineStatus,
  OnboardingProgress,
  AgeVerificationStatus,
  DobChoice,
} from '../../../common/enums';
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
    | 'isBot'
    | 'appleEmailIsPrivateRelay'
    | 'createdAt'
    | 'updatedAt'
    | 'birthdaySkipped'
    | 'onboardingProgress'
    | 'profileCompletenessPct'
    | 'tutorialVersion'
    | 'ageVerificationStatus'
    | 'emailVerified'
    | 'credibilityScore';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

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

  /**
   * True when the email stored above is an Apple private-relay address
   * that is currently forwarding. Updated on Apple S2S email-disabled /
   * email-enabled events, and set at sign-in from the is_private_email
   * claim on the identity token.
   */
  @Property({ type: 'boolean', default: false })
  appleEmailIsPrivateRelay: boolean = false;

  /**
   * Set when Apple sends a consent-revoked S2S notification. The user's
   * sessions are revoked but the account is not deleted — they can still
   * sign in via phone / Google / email. Cleared on successful re-link.
   */
  @Property({ type: 'timestamptz', nullable: true })
  appleConsentRevokedAt?: Date;

  /**
   * Set when Apple sends an account-delete S2S notification. Always
   * accompanies a soft-delete on the user (deletedAt also set). Preserved
   * for audit even after hard-delete.
   */
  @Property({ type: 'timestamptz', nullable: true })
  appleAccountDeletedAt?: Date;

  @Property({ type: 'boolean', default: false })
  @Index()
  isBot: boolean = false;

  /**
   * Identity extensions per IDENTITY_CONTRACT §3.2.
   */
  @Property({ type: 'varchar', length: 50, nullable: true, unique: true })
  username?: string;

  @Property({ type: 'text', nullable: true })
  bio?: string;

  @Property({ type: 'boolean', default: false })
  birthdaySkipped: boolean = false;

  @Enum({ items: () => OnboardingProgress, default: OnboardingProgress.WELCOME })
  onboardingProgress: OnboardingProgress = OnboardingProgress.WELCOME;

  @Property({ type: 'int', default: 0 })
  profileCompletenessPct: number = 0;

  @Property({ type: 'int', default: 0 })
  tutorialVersion: number = 0;

  @Property({ type: 'timestamptz', nullable: true })
  tutorialCompletedAt?: Date;

  @Property({ type: 'timestamptz', nullable: true })
  lastReminderAt?: Date;

  /**
   * Timestamp of the last profile-completeness nudge push sent. Used by
   * `ProfileCompletenessNudgeCron` to enforce the 7-day reminder cadence
   * per IDENTITY_CONTRACT §8.
   */
  @Property({ type: 'timestamptz', nullable: true })
  lastProfileReminderAt?: Date;

  @Property({ type: 'timestamptz', nullable: true })
  lastLoginAt?: Date;

  @Enum({
    items: () => AgeVerificationStatus,
    default: AgeVerificationStatus.SELF_DECLARED,
  })
  ageVerificationStatus: AgeVerificationStatus = AgeVerificationStatus.SELF_DECLARED;

  /**
   * Whether the email on file has been verified via a one-time code.
   * Distinct from the existence of an EMAIL credential row: a user may
   * have registered with email+password (credential exists) but not yet
   * completed the email-verify flow.
   */
  @Property({ type: 'boolean', default: false })
  emailVerified: boolean = false;

  @Property({ type: 'timestamptz', nullable: true })
  emailVerifiedAt?: Date;

  /**
   * Cached aggregate of `trust_signals.delta` for the user. Recomputed
   * by the trust module on signal append; the ledger remains the source
   * of truth.
   */
  @Property({ type: 'int', default: 0 })
  credibilityScore: number = 0;

  /**
   * User's onboarding answer at the DOB step. Stored as varchar(32) so
   * the enum can be extended without a schema migration; see
   * `DobChoice` for the authoritative value set.
   */
  @Enum({ items: () => DobChoice, nullable: true, columnType: 'varchar(32)' })
  dobChoice?: DobChoice;

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
