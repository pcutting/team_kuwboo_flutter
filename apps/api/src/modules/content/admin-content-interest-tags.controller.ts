import { Controller, Post, Body, Param, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ContentInterestTagsService } from './content-interest-tags.service';
import { SetInterestTagsDto } from './dto/set-interest-tags.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { Role } from '../../common/enums';

@ApiTags('admin-content')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/content')
export class AdminContentInterestTagsController {
  constructor(private readonly interestTags: ContentInterestTagsService) {}

  /** Admin retag — replaces the full set on behalf of a moderator. */
  @Post(':id/interest-tags')
  async setInterestTags(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: SetInterestTagsDto,
  ) {
    const ids = await this.interestTags.replaceTags(id, dto.interest_ids, userId);
    return { interest_ids: ids };
  }
}
