import { Injectable, NotImplementedException } from '@nestjs/common';

/**
 * VideoService — thin facade for the Video tab (TikTok-style feed).
 *
 * Delegates to the existing Content STI layer for `Video` entities and
 * the shared `Category` (scope = VIDEO) / `AudioTrack` tables. This
 * service exposes only the video-specific slices: the vertical feed,
 * category browsing, music library, and trending.
 *
 * Scaffold only — every method throws NotImplementedException. Real
 * logic lands with the Milestone 3 implementation phase. See
 * docs/team/internal/TECHNICAL_DESIGN.md Section 3 Part 2 (Video tab)
 * and docs/team/internal/REALTIME_ARCHITECTURE.md Section 4 (feed
 * gateway) for the target design.
 */
@Injectable()
export class VideoService {
  /**
   * Return the vertical (TikTok-style) video feed for the given user,
   * ranked by the mixed-signal feed algorithm described in
   * TECHNICAL_DESIGN.md Section 4.
   */
  async getFeed(_userId: string, _cursor?: string, _limit = 20) {
    throw new NotImplementedException('VideoService.getFeed is not yet implemented');
  }

  /**
   * Return trending videos globally (no user personalisation). Ranked
   * by an engagement-weighted score over a rolling window.
   */
  async getTrending(_limit = 20) {
    throw new NotImplementedException('VideoService.getTrending is not yet implemented');
  }

  /**
   * List active categories scoped to VIDEO content. Seeded from the
   * legacy `video_categories` table (27 categories).
   */
  async listCategories() {
    throw new NotImplementedException('VideoService.listCategories is not yet implemented');
  }

  /**
   * Return videos within a specific category slug, paginated.
   */
  async getByCategory(_slug: string, _cursor?: string, _limit = 20) {
    throw new NotImplementedException('VideoService.getByCategory is not yet implemented');
  }

  /**
   * Fetch a single video by id, including creator, music, and tag
   * relations.
   */
  async getById(_id: string) {
    throw new NotImplementedException('VideoService.getById is not yet implemented');
  }

  /**
   * List or search audio tracks (the music library used for video
   * overlays). Supports query by title/artist and pagination.
   */
  async listAudioTracks(_query?: string, _cursor?: string, _limit = 20) {
    throw new NotImplementedException('VideoService.listAudioTracks is not yet implemented');
  }

  /**
   * Return all videos that use a given audio track (the "original
   * sound" pivot that powers sound-based discovery).
   */
  async getVideosByAudioTrack(_audioTrackId: string, _cursor?: string, _limit = 20) {
    throw new NotImplementedException(
      'VideoService.getVideosByAudioTrack is not yet implemented',
    );
  }
}
