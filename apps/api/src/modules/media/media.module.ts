import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { Media } from './entities/media.entity';
import { MediaService } from './media.service';
import { MediaController } from './media.controller';
import { S3Provider } from './providers/s3.provider';
import { MediaProcessingProcessor } from './workers/media-processing.processor';
import { MEDIA_PROCESSING_QUEUE } from './workers/media-processing.queue';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Media]),
    BullModule.registerQueue({ name: MEDIA_PROCESSING_QUEUE }),
    UsersModule,
  ],
  controllers: [MediaController],
  providers: [MediaService, S3Provider, MediaProcessingProcessor],
  exports: [MediaService],
})
export class MediaModule {}
