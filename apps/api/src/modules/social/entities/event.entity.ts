import { Entity, Property } from '@mikro-orm/core';
import { Content } from '../../content/entities/content.entity';

/**
 * Event CTI child of Content. Used by the Social tab (and thread
 * module key `SOCIAL_STUMBLE`) to represent community events —
 * meetups, gatherings, gigs — with a venue, start/end window, and
 * optional capacity. Attendees are tracked via `InteractionEvent`
 * (SAVE / RSVP) and aggregated into `attendeeCount` by a worker.
 *
 * See docs/team/internal/TECHNICAL_DESIGN.md Section 3 Part 2 ("Social
 * — events") for the entity spec. Scaffold only — business logic lands
 * with the Milestone 3 implementation phase.
 */
@Entity({ discriminatorValue: 'EVENT' })
export class Event extends Content {
  @Property({ type: 'varchar', length: 255 })
  title!: string;

  @Property({ type: 'text', nullable: true })
  description?: string;

  @Property({ type: 'varchar', length: 255, nullable: true })
  venue?: string;

  @Property({ type: 'timestamptz' })
  startsAt!: Date;

  @Property({ type: 'timestamptz' })
  endsAt!: Date;

  @Property({ type: 'int', nullable: true })
  capacity?: number;

  @Property({ type: 'int', default: 0 })
  attendeeCount: number = 0;
}
