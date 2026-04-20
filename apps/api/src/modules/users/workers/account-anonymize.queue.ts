/**
 * Queue + job contract for the 30-day account-anonymize pipeline.
 *
 * `DELETE /users/me` (soft-delete) immediately sets `users.deleted_at`
 * and revokes sessions, then schedules one of these jobs with a
 * 30-day delay. On fire the processor nulls PII columns and flips
 * `status` to `DELETED`. Jobs use a deterministic `jobId` so a repeat
 * soft-delete (should not happen — the endpoint is idempotent at the
 * HTTP level too) is dropped by BullMQ's dedupe.
 */
export const ACCOUNT_ANONYMIZE_QUEUE = 'account-anonymize';

export const ACCOUNT_ANONYMIZE_DELAY_MS = 30 * 24 * 60 * 60 * 1000;

export interface AccountAnonymizeJob {
  userId: string;
  /**
   * The `deletedAt` timestamp observed when the job was scheduled.
   * The processor refuses to run if `users.deleted_at` is either null
   * (the user restored their account before the grace period elapsed)
   * or has moved on to a later value (a second soft-delete rescheduled
   * the 30-day clock). Belt-and-braces on top of the BullMQ dedupe.
   */
  deletedAtIso: string;
}
