import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Roles } from '../../common/decorators/roles.decorator';
import { Role, BotSimulationStatus } from '../../common/enums';
import { BotsService } from './bots.service';
import { BotSchedulerService } from './bot-scheduler.service';
import { BotEngineService } from './bot-engine.service';
import { CreateBotDto } from './dto/create-bot.dto';
import { UpdateBotDto } from './dto/update-bot.dto';
import { BulkCreateBotsDto } from './dto/bulk-create-bots.dto';

@ApiTags('admin/bots')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/bots')
export class BotAdminController {
  constructor(
    private readonly botsService: BotsService,
    private readonly scheduler: BotSchedulerService,
    private readonly engine: BotEngineService,
  ) {}

  @Post()
  async createBot(@Body() dto: CreateBotDto) {
    return this.botsService.createBot(dto);
  }

  @Post('bulk')
  async bulkCreateBots(@Body() dto: BulkCreateBotsDto) {
    const profiles = await this.botsService.bulkCreateBots(dto);
    return { created: profiles.length, profiles };
  }

  @Get()
  async listBots(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('simulationStatus') simulationStatus?: BotSimulationStatus,
    @Query('displayPersona') displayPersona?: string,
  ) {
    return this.botsService.findAll(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      simulationStatus,
      displayPersona,
    );
  }

  @Get('stats')
  async getStats() {
    return this.botsService.getBotStats();
  }

  @Get(':id')
  async getBot(@Param('id', ParseUUIDPipe) id: string) {
    return this.botsService.findById(id);
  }

  @Patch(':id')
  async updateBot(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateBotDto,
  ) {
    return this.botsService.updateBot(id, dto);
  }

  @Delete(':id')
  async deleteBot(@Param('id', ParseUUIDPipe) id: string) {
    await this.scheduler.stopBot(id);
    await this.botsService.deleteBot(id);
    return { message: 'Bot deleted' };
  }

  @Post(':id/start')
  async startBot(@Param('id', ParseUUIDPipe) id: string) {
    await this.scheduler.startBot(id);
    return { message: 'Bot simulation started' };
  }

  @Post(':id/pause')
  async pauseBot(@Param('id', ParseUUIDPipe) id: string) {
    await this.scheduler.pauseBot(id);
    return { message: 'Bot simulation paused' };
  }

  @Post(':id/stop')
  async stopBot(@Param('id', ParseUUIDPipe) id: string) {
    await this.scheduler.stopBot(id);
    return { message: 'Bot simulation stopped' };
  }

  @Post('start-all')
  async startAll() {
    const count = await this.scheduler.startAllBots();
    return { message: `Started ${count} bots` };
  }

  @Post('stop-all')
  async stopAll() {
    const count = await this.scheduler.stopAllBots();
    return { message: `Stopped ${count} bots` };
  }

  @Get(':id/activity')
  async getActivityLog(
    @Param('id', ParseUUIDPipe) id: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.botsService.getActivityLog(
      id,
      cursor,
      limit ? parseInt(limit, 10) : 50,
    );
  }

  @Post(':id/trigger')
  async triggerAction(@Param('id', ParseUUIDPipe) id: string) {
    const profile = await this.botsService.findById(id);
    const result = await this.engine.executeRandomAction(profile);
    return result;
  }

  @Post(':id/reset')
  async resetBot(@Param('id', ParseUUIDPipe) id: string) {
    const profile = await this.botsService.resetBot(id);
    await this.scheduler.startBot(id);
    return { message: 'Bot reset and started', profile };
  }

  @Get(':id/activity/stats')
  async getActivityStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.botsService.getActivityStats(id);
  }
}
