import {
  Body,
  Controller,
  Get,
  Inject,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  BadRequestException,
  forwardRef,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { wrap } from '@mikro-orm/core';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';
import { PatchMeDto } from './dto/patch-me.dto';
import { TutorialCompleteDto } from './dto/tutorial-complete.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ConsentService } from '../consent/consent.service';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    @Inject(forwardRef(() => ConsentService))
    private readonly consentService: ConsentService,
  ) {}

  @Get('me')
  async getMe(@CurrentUser('id') userId: string) {
    const [user, consentStatus] = await Promise.all([
      this.usersService.findById(userId),
      this.consentService.getCurrencyFlags(userId),
    ]);
    // Serialise via the entity wrap/toJSON first so MikroORM's
    // `hidden: true` fields (e.g. passwordHash) are stripped, then
    // merge the out-of-band consentStatus summary. Spreading the
    // managed entity directly would bypass toJSON and leak
    // passwordHash.
    return { ...wrap(user).toJSON(), consentStatus };
  }

  @Patch('me')
  async patchMe(@CurrentUser('id') userId: string, @Body() dto: PatchMeDto) {
    return this.usersService.patchMe(userId, dto);
  }

  @Post('me/tutorial-complete')
  async completeTutorial(
    @CurrentUser('id') userId: string,
    @Body() dto: TutorialCompleteDto,
  ) {
    return this.usersService.markTutorialComplete(userId, dto.version);
  }

  @Get('username-available')
  async usernameAvailable(@Query('handle') handle?: string) {
    if (!handle) {
      throw new BadRequestException({
        code: 'handle_required',
        message: 'handle query parameter is required',
      });
    }
    const available = await this.usersService.usernameAvailable(handle);
    return { available };
  }

  @Get(':id')
  async getProfile(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findById(id);
  }

  @Patch(':id')
  async updateProfile(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.update(id, dto);
  }

  @Patch(':id/preferences')
  async updatePreferences(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePreferencesDto,
  ) {
    return this.usersService.updatePreferences(id, dto);
  }
}
