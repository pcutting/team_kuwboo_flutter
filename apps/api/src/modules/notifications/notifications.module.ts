import { Module, forwardRef } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { JwtModule } from '@nestjs/jwt';
import { Notification } from './entities/notification.entity';
import { NotificationPreference } from './entities/notification-preference.entity';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { NotificationGateway } from './notification.gateway';
import { DevicesModule } from '../devices/devices.module';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';

@Module({
  imports: [
    MikroOrmModule.forFeature([Notification, NotificationPreference]),
    forwardRef(() => DevicesModule),
    JwtModule.register({}),
  ],
  controllers: [NotificationsController],
  providers: [WsAuthGuard, NotificationsService, NotificationGateway],
  exports: [NotificationsService, NotificationGateway],
})
export class NotificationsModule {}
