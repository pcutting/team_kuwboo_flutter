import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Content } from './entities/content.entity';
import { Video } from './entities/video.entity';
import { Post } from './entities/post.entity';
import { Category } from './entities/category.entity';
import { Tag } from './entities/tag.entity';
import { ContentTag } from './entities/content-tag.entity';
import { ContentInterestTag } from './entities/content-interest-tag.entity';
import { AudioTrack } from './entities/audio-track.entity';
import { Product } from './entities/product.entity';
import { ContentService } from './content.service';
import { ContentInterestTagsService } from './content-interest-tags.service';
import { ContentController } from './content.controller';
import { AdminContentInterestTagsController } from './admin-content-interest-tags.controller';
import { UsersModule } from '../users/users.module';
import { Interest } from '../interests/entities/interest.entity';

@Module({
  imports: [
    MikroOrmModule.forFeature([
      Content,
      Video,
      Post,
      Product,
      Category,
      Tag,
      ContentTag,
      ContentInterestTag,
      AudioTrack,
      Interest,
    ]),
    UsersModule,
  ],
  controllers: [ContentController, AdminContentInterestTagsController],
  providers: [ContentService, ContentInterestTagsService],
  exports: [ContentService, ContentInterestTagsService],
})
export class ContentModule {}
