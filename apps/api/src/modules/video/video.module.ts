import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Video } from '../content/entities/video.entity';
import { AudioTrack } from '../content/entities/audio-track.entity';
import { Category } from '../content/entities/category.entity';
import { VideoService } from './video.service';
import { VideoController } from './video.controller';

/**
 * Video module — facade for the TikTok-style video tab (thread module
 * key `VIDEO_MAKING`). Registers the existing Content STI Video entity
 * plus the shared AudioTrack and Category (scope = VIDEO) tables for
 * read access. Does not own any new tables.
 *
 * Scaffold only — see VideoService for the set of handlers that will
 * throw NotImplementedException until the Milestone 3 implementation
 * phase lands.
 */
@Module({
  imports: [MikroOrmModule.forFeature([Video, AudioTrack, Category])],
  controllers: [VideoController],
  providers: [VideoService],
  exports: [VideoService],
})
export class VideoModule {}
