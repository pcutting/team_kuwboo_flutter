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
import { SponsoredService } from './sponsored.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { UpdateCampaignStatusDto } from './dto/update-campaign-status.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';

@ApiTags('sponsored')
@ApiBearerAuth()
@Controller('sponsored/campaigns')
export class SponsoredController {
  constructor(
    private readonly sponsoredService: SponsoredService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async createCampaign(@CurrentUser('id') userId: string, @Body() dto: CreateCampaignDto) {
    const user = await this.usersService.findById(userId);
    return this.sponsoredService.createCampaign(user, dto);
  }

  @Get()
  async getCampaigns(
    @CurrentUser('id') userId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.sponsoredService.getCampaigns(
      userId,
      cursor,
      limit ? parseInt(limit, 10) : 20,
    );
  }

  @Patch(':id')
  async updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateCampaignStatusDto,
  ) {
    return this.sponsoredService.updateCampaignStatus(userId, id, dto.status);
  }
}
