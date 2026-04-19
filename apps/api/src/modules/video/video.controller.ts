import { Controller, Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { VideoService } from './video.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { VideoFeedQueryDto } from './dto/video-feed-query.dto';
import { AudioTracksQueryDto } from './dto/audio-tracks-query.dto';

/**
 * Video module REST surface for the TikTok-style video tab.
 *
 * Scaffold only — every handler delegates to a service method that
 * throws NotImplementedException. Routes, DTOs, auth wiring, and
 * OpenAPI metadata are in place so the mobile client can generate a
 * client and hit the endpoints (getting 501s) during integration.
 *
 * Video creation itself continues to flow through POST /content/videos
 * on ContentController — the Video module is intentionally read-side
 * plus audio-track / category browsing only.
 *
 * Real-time note: a dedicated Socket.io gateway for live video events
 * (new uploads in the vertical feed, live like counters) is planned.
 * See docs/team/internal/REALTIME_ARCHITECTURE.md Section 4. TODO:
 * wire VideoGateway once the REST layer is implemented.
 */
@ApiTags('video')
@ApiBearerAuth()
@Controller('video')
export class VideoController {
  constructor(private readonly videoService: VideoService) {}

  @Get('feed')
  @ApiOperation({
    summary: 'Vertical video feed',
    description: 'Personalised TikTok-style feed of Video content for the current user.',
  })
  async getFeed(@CurrentUser('id') userId: string, @Query() query: VideoFeedQueryDto) {
    return this.videoService.getFeed(userId, query.cursor, query.limit);
  }

  @Public()
  @Get('trending')
  @ApiOperation({
    summary: 'Trending videos',
    description: 'Globally trending videos over a rolling engagement window. No auth required.',
  })
  async getTrending(@Query() query: VideoFeedQueryDto) {
    return this.videoService.getTrending(query.limit);
  }

  @Public()
  @Get('categories')
  @ApiOperation({
    summary: 'List video categories',
    description: 'Returns active categories scoped to VIDEO, seeded from the legacy taxonomy.',
  })
  async listCategories() {
    return this.videoService.listCategories();
  }

  @Public()
  @Get('categories/:slug')
  @ApiOperation({
    summary: 'Videos by category',
    description: 'Paginated list of videos within the given category slug.',
  })
  async getByCategory(@Param('slug') slug: string, @Query() query: VideoFeedQueryDto) {
    return this.videoService.getByCategory(slug, query.cursor, query.limit);
  }

  @Public()
  @Get('audio-tracks')
  @ApiOperation({
    summary: 'Search the audio-track library',
    description: 'List or search audio tracks used for video overlays (music picker).',
  })
  async listAudioTracks(@Query() query: AudioTracksQueryDto) {
    return this.videoService.listAudioTracks(query.q, query.cursor, query.limit);
  }

  @Public()
  @Get('audio-tracks/:id/videos')
  @ApiOperation({
    summary: 'Videos using a given audio track',
    description: 'Returns the set of Video content that uses the referenced AudioTrack.',
  })
  async getVideosByAudioTrack(
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: VideoFeedQueryDto,
  ) {
    return this.videoService.getVideosByAudioTrack(id, query.cursor, query.limit);
  }

  @Public()
  @Get(':id')
  @ApiOperation({
    summary: 'Get a single video',
    description: 'Fetch one Video by id, including creator, music, and tag relations.',
  })
  async getById(@Param('id', ParseUUIDPipe) id: string) {
    return this.videoService.getById(id);
  }
}
