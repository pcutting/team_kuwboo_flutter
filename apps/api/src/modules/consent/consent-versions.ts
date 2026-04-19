/**
 * Currently-shipping versions of the legal documents whose acceptance we
 * audit per-user in `user_consents`. These values are what gets stamped
 * into `UserConsent.version` on new grants and what clients compare
 * against (via `GET /consent/summary`) to decide whether an "implied
 * consent" legal-update banner is required.
 *
 * Bumping either value forces every active user to re-accept on next
 * open (the `isCurrent` flag in the summary flips to false for any
 * consent whose stored version no longer matches the current one).
 *
 * Keep the string format lexicographically comparable (e.g. `1.0`,
 * `1.1`, `2.0`) — `ConsentService.getSummary` uses `MAX(version)` via
 * ordinary string ordering to pick the last-accepted version.
 */
export const CURRENT_CONSENT_VERSIONS = {
  TERMS: '1.0',
  PRIVACY: '1.0',
} as const;

export type CurrentConsentVersions = typeof CURRENT_CONSENT_VERSIONS;
