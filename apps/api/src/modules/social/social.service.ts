import { Injectable, NotImplementedException } from '@nestjs/common';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

/**
 * SocialService — facade for the Social tab (thread module key
 * `SOCIAL_STUMBLE`). Surfaces the social feed, the "stumble" discovery
 * stream, friend suggestions, and event CRUD. Post creation itself
 * still flows through POST /content/posts on ContentController — this
 * service delegates to shared infrastructure (ContentService,
 * ConnectionsService) for everything except Event-specific writes.
 *
 * Scaffold only — every method throws NotImplementedException. See
 * docs/team/internal/TECHNICAL_DESIGN.md Section 3 Part 2 (Social tab)
 * and docs/team/internal/REALTIME_ARCHITECTURE.md for the target
 * design.
 */
@Injectable()
export class SocialService {
  /**
   * Social-tab feed: posts + events from followed users and friends,
   * optionally scoped to a geographic radius for local discovery.
   */
  async getFeed(
    _userId: string,
    _cursor?: string,
    _limit = 20,
    _lat?: number,
    _lng?: number,
    _radiusKm?: number,
  ) {
    throw new NotImplementedException('SocialService.getFeed is not yet implemented');
  }

  /**
   * Social-stumble discovery stream: suggestions of profiles, posts,
   * and events outside the user's existing connections, tuned for
   * lateral discovery rather than feed recency.
   */
  async getStumble(_userId: string, _cursor?: string, _limit = 20) {
    throw new NotImplementedException('SocialService.getStumble is not yet implemented');
  }

  /**
   * Return friend suggestions for the user — ranked by mutual friends,
   * shared interests, and proximity.
   */
  async getFriendSuggestions(_userId: string, _limit = 20) {
    throw new NotImplementedException(
      'SocialService.getFriendSuggestions is not yet implemented',
    );
  }

  /**
   * Create an Event (CTI child of Content) owned by the current user.
   */
  async createEvent(_userId: string, _dto: CreateEventDto) {
    throw new NotImplementedException('SocialService.createEvent is not yet implemented');
  }

  /**
   * Update an Event. Only the creator or an admin may mutate fields.
   */
  async updateEvent(_userId: string, _eventId: string, _dto: UpdateEventDto) {
    throw new NotImplementedException('SocialService.updateEvent is not yet implemented');
  }

  /**
   * List upcoming events, optionally scoped to a geographic radius.
   */
  async listEvents(
    _cursor?: string,
    _limit = 20,
    _lat?: number,
    _lng?: number,
    _radiusKm?: number,
  ) {
    throw new NotImplementedException('SocialService.listEvents is not yet implemented');
  }

  /**
   * Fetch a single event by id.
   */
  async getEventById(_eventId: string) {
    throw new NotImplementedException('SocialService.getEventById is not yet implemented');
  }

  /**
   * Register the current user as an attendee of the given event. Emits
   * an `InteractionEvent` of type RSVP and increments `attendeeCount`
   * via a worker.
   */
  async rsvpToEvent(_userId: string, _eventId: string) {
    throw new NotImplementedException('SocialService.rsvpToEvent is not yet implemented');
  }

  /**
   * Cancel a previous RSVP for the given event.
   */
  async cancelRsvp(_userId: string, _eventId: string) {
    throw new NotImplementedException('SocialService.cancelRsvp is not yet implemented');
  }
}
