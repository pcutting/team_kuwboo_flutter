import { Controller, Post, Delete, Body, Param, Inject, forwardRef } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { DevicesService } from './devices.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';

@ApiTags('devices')
@ApiBearerAuth()
@Controller('devices')
export class DevicesController {
  constructor(
    private readonly devicesService: DevicesService,
    @Inject(forwardRef(() => UsersService))
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async register(@CurrentUser('id') userId: string, @Body() dto: RegisterDeviceDto) {
    const user = await this.usersService.findById(userId);
    return this.devicesService.register(user, dto);
  }

  @Delete(':fcmToken')
  async deactivate(@Param('fcmToken') fcmToken: string) {
    await this.devicesService.deactivate(fcmToken);
    return { message: 'Device deactivated' };
  }
}
