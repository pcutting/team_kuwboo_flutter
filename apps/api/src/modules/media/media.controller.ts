import { Controller, Post, Get, Body, Param, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOkResponse } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { PresignedUrlRequestDto } from './dto/presigned-url.dto';
import { MediaResponseDto } from './dto/media-response.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';

@ApiTags('media')
@ApiBearerAuth()
@Controller('media')
export class MediaController {
  constructor(
    private readonly mediaService: MediaService,
    private readonly usersService: UsersService,
  ) {}

  @Post('presigned-url')
  async getPresignedUrl(
    @CurrentUser('id') userId: string,
    @Body() dto: PresignedUrlRequestDto,
  ) {
    const user = await this.usersService.findById(userId);
    return this.mediaService.generatePresignedUrl(user, dto);
  }

  @Post(':id/confirm')
  async confirmUpload(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
  ): Promise<MediaResponseDto> {
    const media = await this.mediaService.confirmUpload(id, userId);
    return MediaResponseDto.fromEntity(media);
  }

  @Get(':id')
  @ApiOkResponse({ type: MediaResponseDto })
  async findById(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<MediaResponseDto> {
    const media = await this.mediaService.findById(id);
    return MediaResponseDto.fromEntity(media);
  }
}
