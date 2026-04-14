/**
 * Trust signal types per IDENTITY_CONTRACT §7 + TRUST_ENGINE §2.
 *
 * Stored as free text in `trust_signals.signal_type` so moderation / future
 * signals can be appended without a schema change; this enum is the
 * authoritative list of values emitted by the identity subsystem.
 */
export enum TrustSignalType {
  PHONE_VERIFIED_MOBILE = 'phone_verified_mobile',
  PHONE_VERIFIED_VOIP = 'phone_verified_voip',
  EMAIL_VERIFIED = 'email_verified',
  SSO_GOOGLE_VERIFIED = 'sso_google_verified',
  SSO_APPLE_VERIFIED = 'sso_apple_verified',
  REFRESH_REUSE_DETECTED = 'refresh_reuse_detected',
  ACCOUNT_AGE_30D = 'account_age_30d',
  SELFIE_VERIFIED = 'selfie_verified',
  AGE_PROVIDER_VERIFIED = 'age_provider_verified',
}
