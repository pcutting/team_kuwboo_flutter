import { Controller, Post, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { InteractionsService } from './interactions.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('interactions')
@ApiBearerAuth()
@Controller('content')
export class InteractionsController {
  constructor(private readonly interactionsService: InteractionsService) {}

  @Post(':id/like')
  async toggleLike(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    return this.interactionsService.toggleLike(userId, id);
  }

  @Post(':id/save')
  async toggleSave(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    return this.interactionsService.toggleSave(userId, id);
  }

  @Post(':id/view')
  async logView(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    await this.interactionsService.logView(userId, id);
    return { message: 'View logged' };
  }

  @Post(':id/share')
  async logShare(@Param('id', ParseUUIDPipe) id: string, @CurrentUser('id') userId: string) {
    await this.interactionsService.logShare(userId, id);
    return { message: 'Share logged' };
  }

  @Get(':id/interactions')
  async getUserInteractions(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.interactionsService.getUserInteractions(userId, id);
  }
}
