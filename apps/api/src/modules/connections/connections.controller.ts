import { Controller, Post, Get, Delete, Body, Param, Query, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { IsUUID, IsOptional, IsEnum } from 'class-validator';
import { ConnectionsService } from './connections.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ModuleScope } from '../../common/enums';

class FollowDto {
  @IsUUID()
  userId!: string;

  @IsOptional()
  @IsEnum(ModuleScope)
  moduleScope?: ModuleScope;
}

class BlockDto {
  @IsUUID()
  userId!: string;
}

@ApiTags('connections')
@ApiBearerAuth()
@Controller('connections')
export class ConnectionsController {
  constructor(private readonly connectionsService: ConnectionsService) {}

  @Post('follow')
  async follow(@CurrentUser('id') fromUserId: string, @Body() dto: FollowDto) {
    return this.connectionsService.follow(fromUserId, dto.userId, dto.moduleScope);
  }

  @Delete('follow/:userId')
  async unfollow(
    @CurrentUser('id') fromUserId: string,
    @Param('userId', ParseUUIDPipe) toUserId: string,
    @Query('moduleScope') moduleScope?: ModuleScope,
  ) {
    await this.connectionsService.unfollow(fromUserId, toUserId, moduleScope);
    return { message: 'Unfollowed' };
  }

  @Post('friend-request')
  async sendFriendRequest(@CurrentUser('id') fromUserId: string, @Body() dto: FollowDto) {
    return this.connectionsService.sendFriendRequest(fromUserId, dto.userId);
  }

  @Post('friend-request/:id/accept')
  async acceptFriendRequest(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.connectionsService.acceptFriendRequest(id, userId);
  }

  @Post('friend-request/:id/reject')
  async rejectFriendRequest(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
  ) {
    await this.connectionsService.rejectFriendRequest(id, userId);
    return { message: 'Friend request rejected' };
  }

  @Get('followers')
  async getFollowers(@CurrentUser('id') userId: string, @Query('limit') limit?: string, @Query('offset') offset?: string) {
    return this.connectionsService.getFollowers(userId, limit ? parseInt(limit, 10) : 20, offset ? parseInt(offset, 10) : 0);
  }

  @Get('following')
  async getFollowing(@CurrentUser('id') userId: string, @Query('limit') limit?: string, @Query('offset') offset?: string) {
    return this.connectionsService.getFollowing(userId, limit ? parseInt(limit, 10) : 20, offset ? parseInt(offset, 10) : 0);
  }

  @Post('block')
  async block(@CurrentUser('id') blockerId: string, @Body() dto: BlockDto) {
    return this.connectionsService.block(blockerId, dto.userId);
  }

  @Delete('block/:userId')
  async unblock(@CurrentUser('id') blockerId: string, @Param('userId', ParseUUIDPipe) blockedId: string) {
    await this.connectionsService.unblock(blockerId, blockedId);
    return { message: 'Unblocked' };
  }

  @Get('blocks')
  async getBlocks(@CurrentUser('id') userId: string) {
    return this.connectionsService.getBlocks(userId);
  }
}
