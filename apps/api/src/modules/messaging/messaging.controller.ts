import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { MessagingService } from './messaging.service';
import { CreateThreadDto } from './dto/create-thread.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';

@ApiTags('messaging')
@ApiBearerAuth()
@Controller('threads')
export class MessagingController {
  constructor(
    private readonly messagingService: MessagingService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async createThread(@CurrentUser('id') userId: string, @Body() dto: CreateThreadDto) {
    const user = await this.usersService.findById(userId);
    return this.messagingService.createThread(user, dto);
  }

  @Get()
  async getThreads(
    @CurrentUser('id') userId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.messagingService.getThreads(userId, cursor, limit ? parseInt(limit, 10) : 20);
  }

  @Get(':id/messages')
  async getMessages(
    @Param('id', ParseUUIDPipe) threadId: string,
    @CurrentUser('id') userId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.messagingService.getMessages(
      userId,
      threadId,
      cursor,
      limit ? parseInt(limit, 10) : 50,
    );
  }

  @Post(':id/messages')
  async sendMessage(
    @Param('id', ParseUUIDPipe) threadId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: SendMessageDto,
  ) {
    const user = await this.usersService.findById(userId);
    return this.messagingService.sendMessage(user, threadId, dto);
  }

  @Patch(':id/read')
  async markRead(
    @Param('id', ParseUUIDPipe) threadId: string,
    @CurrentUser('id') userId: string,
  ) {
    await this.messagingService.markRead(userId, threadId);
    return { message: 'Thread marked as read' };
  }
}
