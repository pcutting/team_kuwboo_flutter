import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { DatingService } from './dating.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { DatingAgeGuard } from '../../common/guards/dating-age.guard';

@ApiTags('dating')
@ApiBearerAuth()
@Controller('dating')
@UseGuards(JwtAuthGuard, DatingAgeGuard)
export class DatingController {
  constructor(private readonly service: DatingService) {}

  @Get('discover')
  discover(
    @CurrentUser('id') userId: string,
    @Query('cursor') cursor?: string,
  ) {
    return this.service.discover(userId, cursor);
  }

  @Get('matches')
  matches(@CurrentUser('id') userId: string) {
    return this.service.matches(userId);
  }

  @Get('likes')
  likes(@CurrentUser('id') userId: string) {
    return this.service.likes(userId);
  }
}
