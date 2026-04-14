/**
 * Queue + job contract for the profile-completeness nudge pipeline (D3a).
 * Kept in its own file so the cron (producer) and processor (consumer)
 * can import the shape without creating a circular reference through the
 * workers' own implementations.
 */
export const PROFILE_COMPLETENESS_NUDGE_QUEUE = 'profile-completeness-nudge';

export interface ProfileCompletenessNudgeJob {
  userId: string;
  completenessPct: number;
  missingFields: string[];
}
