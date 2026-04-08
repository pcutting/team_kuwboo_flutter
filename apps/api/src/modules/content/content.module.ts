import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Content } from './entities/content.entity';
import { Video } from './entities/video.entity';
import { Post } from './entities/post.entity';
import { Category } from './entities/category.entity';
import { Tag } from './entities/tag.entity';
import { ContentTag } from './entities/content-tag.entity';
import { AudioTrack } from './entities/audio-track.entity';
import { Product } from './entities/product.entity';
import { ContentService } from './content.service';
import { ContentController } from './content.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Content, Video, Post, Product, Category, Tag, ContentTag, AudioTrack]),
    UsersModule,
  ],
  controllers: [ContentController],
  providers: [ContentService],
  exports: [ContentService],
})
export class ContentModule {}
