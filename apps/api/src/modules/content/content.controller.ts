import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ContentService } from './content.service';
import { ContentInterestTagsService } from './content-interest-tags.service';
import { CreateVideoDto } from './dto/create-video.dto';
import { CreatePostDto } from './dto/create-post.dto';
import { SetInterestTagsDto } from './dto/set-interest-tags.dto';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';
import { ContentStatus } from '../../common/enums';

@ApiTags('content')
@ApiBearerAuth()
@Controller('content')
export class ContentController {
  constructor(
    private readonly contentService: ContentService,
    private readonly usersService: UsersService,
    private readonly interestTags: ContentInterestTagsService,
  ) {}

  @Post('videos')
  async createVideo(@CurrentUser('id') userId: string, @Body() dto: CreateVideoDto) {
    const user = await this.usersService.findById(userId);
    return this.contentService.createVideo(user, dto);
  }

  @Post('posts')
  async createPost(@CurrentUser('id') userId: string, @Body() dto: CreatePostDto) {
    const user = await this.usersService.findById(userId);
    return this.contentService.createPost(user, dto);
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.contentService.findById(id);
  }

  @Patch(':id/hide')
  async hide(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    return this.contentService.updateStatus(id, ContentStatus.HIDDEN, userId);
  }

  @Patch(':id/unhide')
  async unhide(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    return this.contentService.updateStatus(id, ContentStatus.ACTIVE, userId);
  }

  @Delete(':id')
  async remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    await this.contentService.softDelete(id, userId);
    return { message: 'Content deleted' };
  }

  @Public()
  @Get(':id/interest-tags')
  async listInterestTags(@Param('id', ParseUUIDPipe) id: string) {
    const rows = await this.interestTags.getTagsForContent(id);
    return {
      interest_tags: rows.map((r) => ({
        interest_id: r.interest.id,
        slug: r.interest.slug,
        label: r.interest.label,
        confidence: r.confidence,
        assigned_at: r.assignedAt,
      })),
    };
  }

  /**
   * Creator-only: replace the full set of interest tags for a content.
   * Admins should use POST /admin/content/:id/interest-tags instead.
   */
  @Post(':id/interest-tags')
  async setInterestTags(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: SetInterestTagsDto,
  ) {
    const content = await this.contentService.findById(id);
    if (content.creator.id !== userId) {
      throw new ForbiddenException('Not the content creator');
    }
    const ids = await this.interestTags.replaceTags(id, dto.interest_ids, userId);
    return { interest_ids: ids };
  }
}
