import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { InterestsService } from './interests.service';
import { SelectInterestsDto } from './dto/select-interests.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('interests')
@Controller()
export class InterestsController {
  constructor(private readonly service: InterestsService) {}

  @Public()
  @Get('interests')
  async listActive() {
    const interests = await this.service.listActive();
    return { interests };
  }

  @ApiBearerAuth()
  @Get('users/me/interests')
  async listMine(@CurrentUser('id') userId: string) {
    const rows = await this.service.listMine(userId);
    return { interests: rows };
  }

  @ApiBearerAuth()
  @Post('users/me/interests')
  async selectMine(
    @CurrentUser('id') userId: string,
    @Body() dto: SelectInterestsDto,
  ) {
    const rows = await this.service.selectMany(userId, dto.interest_ids);
    return { interests: rows };
  }

  @ApiBearerAuth()
  @Delete('users/me/interests/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deselectMine(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) interestId: string,
  ): Promise<void> {
    await this.service.deselect(userId, interestId);
  }
}
