import { Controller, Post, Get, Patch, Delete, Body, Param, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ContentService } from './content.service';
import { CreateVideoDto } from './dto/create-video.dto';
import { CreatePostDto } from './dto/create-post.dto';
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
}
