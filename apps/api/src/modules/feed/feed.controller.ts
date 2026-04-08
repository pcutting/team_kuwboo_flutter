import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { FeedService } from './feed.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ModuleScope } from '../../common/enums';

@ApiTags('feed')
@ApiBearerAuth()
@Controller('feed')
export class FeedController {
  constructor(private readonly feedService: FeedService) {}

  @Get()
  async getFeed(
    @CurrentUser('id') userId: string,
    @Query('tab') tab: string = 'home',
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.feedService.getFeed({
      tab: tab as any,
      cursor,
      limit: limit ? parseInt(limit, 10) : 20,
      userId,
    });
  }

  @Get('following')
  async getFollowingFeed(
    @CurrentUser('id') userId: string,
    @Query('tab') tab: string = 'home',
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
    @Query('moduleScope') moduleScope?: ModuleScope,
  ) {
    return this.feedService.getFollowingFeed(
      {
        tab: tab as any,
        cursor,
        limit: limit ? parseInt(limit, 10) : 20,
        userId,
      },
      moduleScope,
    );
  }

  @Get('trending')
  async getTrending(@Query('tab') tab: string = 'home', @Query('limit') limit?: string) {
    return this.feedService.getTrending(tab, limit ? parseInt(limit, 10) : 20);
  }

  @Get('discover')
  async getDiscover(
    @CurrentUser('id') userId: string,
    @Query('tab') tab: string = 'home',
    @Query('limit') limit?: string,
  ) {
    return this.feedService.getDiscover(userId, tab, limit ? parseInt(limit, 10) : 20);
  }
}
