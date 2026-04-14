import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  BadRequestException,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';
import { PatchMeDto } from './dto/patch-me.dto';
import { TutorialCompleteDto } from './dto/tutorial-complete.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  async getMe(@CurrentUser('id') userId: string) {
    return this.usersService.findById(userId);
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
