import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Event } from './entities/event.entity';
import { Post } from '../content/entities/post.entity';
import { Content } from '../content/entities/content.entity';
import { SocialService } from './social.service';
import { SocialController } from './social.controller';

/**
 * Social module — facade for the Social tab (thread module key
 * `SOCIAL_STUMBLE`). Owns the Event CTI child entity; reuses the
 * existing Post entity and the Content base for queries.
 *
 * Scaffold only — see SocialService for the set of handlers that will
 * throw NotImplementedException until the Milestone 3 implementation
 * phase lands.
 */
@Module({
  imports: [MikroOrmModule.forFeature([Event, Post, Content])],
  controllers: [SocialController],
  providers: [SocialService],
  exports: [SocialService],
})
export class SocialModule {}
