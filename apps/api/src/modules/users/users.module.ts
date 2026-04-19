import { Module, forwardRef } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { User } from './entities/user.entity';
import { UserPreferences } from './entities/user-preferences.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { NotificationsModule } from '../notifications/notifications.module';
import { ProfileCompletenessNudgeCron } from './workers/profile-completeness-nudge.cron';
import { ProfileCompletenessNudgeProcessor } from './workers/profile-completeness-nudge.processor';
import { PROFILE_COMPLETENESS_NUDGE_QUEUE } from './workers/profile-completeness-nudge.queue';
import { ConsentModule } from '../consent/consent.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([User, UserPreferences]),
    BullModule.registerQueue({ name: PROFILE_COMPLETENESS_NUDGE_QUEUE }),
    forwardRef(() => NotificationsModule),
    forwardRef(() => ConsentModule),
  ],
  controllers: [UsersController],
  providers: [
    UsersService,
    ProfileCompletenessNudgeCron,
    ProfileCompletenessNudgeProcessor,
  ],
  exports: [UsersService],
})
export class UsersModule {}
