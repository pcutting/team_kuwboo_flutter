import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { YoyoService } from './yoyo.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UpdateLocationDto } from './dto/update-location.dto';
import { UpdateYoyoSettingsDto } from './dto/update-yoyo-settings.dto';
import { CreateOverrideDto } from './dto/create-override.dto';
import { SendWaveDto } from './dto/send-wave.dto';
import { RespondWaveDto } from './dto/respond-wave.dto';

@ApiTags('yoyo')
@ApiBearerAuth()
@Controller('yoyo')
export class YoyoController {
  constructor(private readonly yoyoService: YoyoService) {}

  @Post('location')
  async updateLocation(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateLocationDto,
  ) {
    await this.yoyoService.updateLocation(userId, dto.latitude, dto.longitude);
    return { message: 'Location updated' };
  }

  @Get('nearby')
  async getNearbyUsers(
    @CurrentUser('id') userId: string,
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radius') radius?: string,
  ) {
    return this.yoyoService.getNearbyUsers(
      userId,
      parseFloat(lat),
      parseFloat(lng),
      radius ? parseInt(radius, 10) : undefined,
    );
  }

  @Get('settings')
  async getSettings(@CurrentUser('id') userId: string) {
    return this.yoyoService.getSettings(userId);
  }

  @Patch('settings')
  async updateSettings(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateYoyoSettingsDto,
  ) {
    return this.yoyoService.updateSettings(userId, dto);
  }

  @Post('overrides')
  async createOverride(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateOverrideDto,
  ) {
    return this.yoyoService.createOverride(userId, dto.targetUserId, dto.action);
  }

  @Post('wave')
  async sendWave(
    @CurrentUser('id') userId: string,
    @Body() dto: SendWaveDto,
  ) {
    return this.yoyoService.sendWave(userId, dto.toUserId, dto.message);
  }

  @Get('waves')
  async getIncomingWaves(@CurrentUser('id') userId: string) {
    return this.yoyoService.getIncomingWaves(userId);
  }

  @Post('waves/:id/respond')
  async respondToWave(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: RespondWaveDto,
  ) {
    return this.yoyoService.respondToWave(id, userId, dto.accept);
  }
}
