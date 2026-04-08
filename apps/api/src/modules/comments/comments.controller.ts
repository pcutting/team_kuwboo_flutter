import { Controller, Post, Get, Delete, Body, Param, Query, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { IsString, IsOptional, IsUUID, MaxLength } from 'class-validator';
import { CommentsService } from './comments.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

class CreateCommentDto {
  @IsString()
  @MaxLength(2000)
  text!: string;

  @IsOptional()
  @IsUUID()
  parentCommentId?: string;
}

@ApiTags('comments')
@ApiBearerAuth()
@Controller()
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Post('content/:contentId/comments')
  async create(
    @Param('contentId', ParseUUIDPipe) contentId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateCommentDto,
  ) {
    return this.commentsService.create(userId, contentId, dto.text, dto.parentCommentId);
  }

  @Get('content/:contentId/comments')
  async list(
    @Param('contentId', ParseUUIDPipe) contentId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.commentsService.getForContent(contentId, cursor, limit ? parseInt(limit, 10) : 20);
  }

  @Post('comments/:id/like')
  async like(@Param('id', ParseUUIDPipe) id: string) {
    return this.commentsService.toggleLike(id);
  }

  @Delete('comments/:id')
  async remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    await this.commentsService.softDelete(id, userId);
    return { message: 'Comment deleted' };
  }
}
