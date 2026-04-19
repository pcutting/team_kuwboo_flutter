import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { UserConsent } from './entities/user-consent.entity';
import { GrantConsentDto } from './dto/grant-consent.dto';
import { User } from '../users/entities/user.entity';
import { ConsentType, ConsentSource } from '../../common/enums';
import { CURRENT_CONSENT_VERSIONS } from './consent-versions';

export interface ConsentSummaryEntry {
  firstAcceptedAt: string | null;
  lastAcceptedAt: string | null;
  acceptedVersion: string | null;
  isCurrent: boolean;
}

export interface ConsentSummary {
  versions: {
    terms: string;
    privacy: string;
  };
  user: {
    terms: ConsentSummaryEntry;
    privacy: ConsentSummaryEntry;
  };
}

@Injectable()
export class ConsentService {
  constructor(private readonly em: EntityManager) {}

  async grant(user: User, dto: GrantConsentDto, ipAddress?: string): Promise<UserConsent> {
    // Revoke previous version of same consent type (if any)
    const existing = await this.em.findOne(UserConsent, {
      user,
      consentType: dto.consentType,
      revokedAt: null,
    });
    if (existing) {
      existing.revokedAt = new Date();
    }

    const consent = this.em.create(UserConsent, {
      user,
      consentType: dto.consentType,
      version: dto.version,
      source: dto.source,
      ipAddress,
    } as any);

    await this.em.flush();
    return consent;
  }

  async revoke(userId: string, consentType: ConsentType): Promise<void> {
    await this.em.nativeUpdate(
      UserConsent,
      { user: { id: userId }, consentType, revokedAt: null },
      { revokedAt: new Date() },
    );
  }

  async getActiveConsents(userId: string): Promise<UserConsent[]> {
    return this.em.find(UserConsent, { user: { id: userId }, revokedAt: null });
  }

  async hasActiveConsent(userId: string, consentType: ConsentType): Promise<boolean> {
    const count = await this.em.count(UserConsent, {
      user: { id: userId },
      consentType,
      revokedAt: null,
    });
    return count > 0;
  }

  /**
   * Record the TERMS and PRIVACY acceptances that came from the
   * email-register flow. Writes two rows at the current document
   * versions with source=REGISTRATION, capturing the calling
   * request's IP and user agent. Flushes once so either both rows
   * land or neither (the `(user, consent_type, version)` unique
   * constraint keeps a retried register idempotent per-version).
   */
  async recordRegistrationConsents(
    user: User,
    meta: { ipAddress?: string; userAgent?: string } = {},
  ): Promise<void> {
    this.em.create(UserConsent, {
      user,
      consentType: ConsentType.TERMS,
      version: CURRENT_CONSENT_VERSIONS.TERMS,
      source: ConsentSource.REGISTRATION,
      ipAddress: meta.ipAddress,
      userAgent: meta.userAgent,
    } as never);
    this.em.create(UserConsent, {
      user,
      consentType: ConsentType.PRIVACY,
      version: CURRENT_CONSENT_VERSIONS.PRIVACY,
      source: ConsentSource.REGISTRATION,
      ipAddress: meta.ipAddress,
      userAgent: meta.userAgent,
    } as never);
    await this.em.flush();
  }

  /**
   * Summary math for `GET /consent/summary`. Aggregates TERMS and
   * PRIVACY grants for a single user, returning first/last acceptance
   * timestamps and the last-accepted version per type.
   *
   * `lastAcceptedVersion` is derived via `MAX(version)` with plain
   * string ordering — this is correct for the current
   * `<major>.<minor>` single-digit scheme (`1.0` < `1.1` < `2.0`). If
   * we ever need two-digit minors (`1.10`) we'll switch to a numeric
   * split or a semver comparator; document the limit here so future
   * readers know to revisit.
   */
  async getSummary(userId: string): Promise<ConsentSummary> {
    const [terms, privacy] = await Promise.all([
      this.summaryFor(userId, ConsentType.TERMS),
      this.summaryFor(userId, ConsentType.PRIVACY),
    ]);

    return {
      versions: {
        terms: CURRENT_CONSENT_VERSIONS.TERMS,
        privacy: CURRENT_CONSENT_VERSIONS.PRIVACY,
      },
      user: {
        terms: withCurrency(terms, CURRENT_CONSENT_VERSIONS.TERMS),
        privacy: withCurrency(privacy, CURRENT_CONSENT_VERSIONS.PRIVACY),
      },
    };
  }

  private async summaryFor(
    userId: string,
    consentType: ConsentType,
  ): Promise<Omit<ConsentSummaryEntry, 'isCurrent'>> {
    const conn = this.em.getConnection();
    // MikroORM's conn.execute runs through Knex, which expects `?` positional
    // placeholders — using `$1`/`$2` directly leaves literal dollar-markers in
    // the SQL while Knex sends zero bindings, producing the runtime error
    // "there is no parameter $1" from pg.
    const rows = (await conn.execute(
      `select
         min("granted_at") as "first",
         max("granted_at") as "last",
         max("version")    as "version"
       from "user_consents"
       where "user_id" = ? and "consent_type" = ?`,
      [userId, consentType],
    )) as Array<{ first: Date | null; last: Date | null; version: string | null }>;

    const row = rows[0] ?? { first: null, last: null, version: null };
    return {
      firstAcceptedAt: row.first ? new Date(row.first).toISOString() : null,
      lastAcceptedAt: row.last ? new Date(row.last).toISOString() : null,
      acceptedVersion: row.version,
    };
  }

  /**
   * Convenience for the /users/me consentStatus payload — reuses the
   * same staleness derivation as `getSummary` without shipping the
   * full dates.
   */
  async getCurrencyFlags(userId: string): Promise<{
    termsUpToDate: boolean;
    privacyUpToDate: boolean;
  }> {
    const summary = await this.getSummary(userId);
    return {
      termsUpToDate: summary.user.terms.isCurrent,
      privacyUpToDate: summary.user.privacy.isCurrent,
    };
  }
}

function withCurrency(
  entry: Omit<ConsentSummaryEntry, 'isCurrent'>,
  currentVersion: string,
): ConsentSummaryEntry {
  return {
    ...entry,
    isCurrent: entry.acceptedVersion === currentVersion,
  };
}
