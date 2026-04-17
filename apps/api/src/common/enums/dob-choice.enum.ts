/**
 * Represents the user's selection for the date-of-birth onboarding step.
 *
 * Stored as a free-form `varchar(32)` in the database so we can extend
 * the allowed set later (e.g. `guardian_verified`) without a schema
 * migration; the enum here is the authoritative list of values that
 * application code emits.
 */
export enum DobChoice {
  /** User supplied an exact date of birth. */
  PROVIDED = 'provided',
  /** User confirmed 18+ without giving an exact DOB. */
  ADULT_SELF_DECLARED = 'adult_self_declared',
  /** User declined to answer. */
  PREFER_NOT_TO_SAY = 'prefer_not_to_say',
  /** User explicitly skipped the step (may revisit later). */
  SKIPPED = 'skipped',
  /** User has not yet been prompted, or has no recorded choice. */
  PENDING = 'pending',
}
