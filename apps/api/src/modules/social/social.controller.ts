import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { SocialService } from './social.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { SocialFeedQueryDto } from './dto/social-feed-query.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

/**
 * Social module REST surface for the Social tab (thread module key
 * `SOCIAL_STUMBLE`).
 *
 * Scaffold only — every handler delegates to a service method that
 * throws NotImplementedException. Post creation remains at POST
 * /content/posts; this controller covers social-specific discovery and
 * the Event subtype.
 *
 * Real-time note: a dedicated Socket.io gateway for live social-feed
 * events (new posts from followed users, event RSVP deltas) is planned.
 * See docs/team/internal/REALTIME_ARCHITECTURE.md Section 4. TODO:
 * wire SocialGateway once the REST layer is implemented.
 */
@ApiTags('social')
@ApiBearerAuth()
@Controller('social')
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Get('feed')
  @ApiOperation({
    summary: 'Social feed',
    description:
      'Social-tab feed (posts + events) for the current user, optionally scoped to a location radius.',
  })
  async getFeed(@CurrentUser('id') userId: string, @Query() query: SocialFeedQueryDto) {
    return this.socialService.getFeed(
      userId,
      query.cursor,
      query.limit,
      query.lat,
      query.lng,
      query.radiusKm,
    );
  }

  @Get('stumble')
  @ApiOperation({
    summary: 'Social stumble discovery',
    description:
      'Lateral discovery stream: suggested profiles, posts, and events outside the user’s existing connections.',
  })
  async getStumble(@CurrentUser('id') userId: string, @Query() query: SocialFeedQueryDto) {
    return this.socialService.getStumble(userId, query.cursor, query.limit);
  }

  @Get('friend-suggestions')
  @ApiOperation({
    summary: 'Friend suggestions',
    description:
      'Ranked list of users the current user might know, based on mutual friends, shared interests, and proximity.',
  })
  async getFriendSuggestions(
    @CurrentUser('id') userId: string,
    @Query() query: SocialFeedQueryDto,
  ) {
    return this.socialService.getFriendSuggestions(userId, query.limit);
  }

  @Post('events')
  @ApiOperation({
    summary: 'Create an event',
    description: 'Create a new Event (CTI child of Content) owned by the current user.',
  })
  async createEvent(@CurrentUser('id') userId: string, @Body() dto: CreateEventDto) {
    return this.socialService.createEvent(userId, dto);
  }

  @Patch('events/:id')
  @ApiOperation({
    summary: 'Update an event',
    description: 'Update an Event. Only the creator (or an admin) may mutate fields.',
  })
  async updateEvent(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateEventDto,
  ) {
    return this.socialService.updateEvent(userId, id, dto);
  }

  @Public()
  @Get('events')
  @ApiOperation({
    summary: 'List upcoming events',
    description: 'Paginated list of upcoming events, optionally scoped to a location radius.',
  })
  async listEvents(@Query() query: SocialFeedQueryDto) {
    return this.socialService.listEvents(
      query.cursor,
      query.limit,
      query.lat,
      query.lng,
      query.radiusKm,
    );
  }

  @Public()
  @Get('events/:id')
  @ApiOperation({
    summary: 'Get a single event',
    description: 'Fetch one Event by id.',
  })
  async getEventById(@Param('id', ParseUUIDPipe) id: string) {
    return this.socialService.getEventById(id);
  }

  @Post('events/:id/rsvp')
  @ApiOperation({
    summary: 'RSVP to an event',
    description: 'Register the current user as an attendee of the given event.',
  })
  async rsvp(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.socialService.rsvpToEvent(userId, id);
  }

  @Delete('events/:id/rsvp')
  @ApiOperation({
    summary: 'Cancel RSVP',
    description: 'Remove the current user from the event attendee list.',
  })
  async cancelRsvp(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.socialService.cancelRsvp(userId, id);
  }
}
