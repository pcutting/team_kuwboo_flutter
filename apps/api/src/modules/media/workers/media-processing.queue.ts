/**
 * Queue + job contract for the async media processing pipeline.
 *
 * `POST /media/:id/confirm` verifies the original upload exists on S3
 * then enqueues one of these jobs; the processor downloads the
 * original, generates thumbnails (and, for video, a 720p H.264 MP4
 * transcode), uploads the derivatives back to S3 under
 * `media/{mediaId}/thumb.jpg` and `media/{mediaId}/720p.mp4`, and
 * flips `media.status` from `PROCESSING` to `READY` (or `FAILED` on
 * terminal failure after retries).
 */
export const MEDIA_PROCESSING_QUEUE = 'media-processing';

export interface MediaProcessJob {
  mediaId: string;
}
