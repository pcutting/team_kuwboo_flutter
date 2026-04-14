import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { Interest } from './entities/interest.entity';
import { UserInterest } from './entities/user-interest.entity';
import { InterestSignal } from './entities/interest-signal.entity';
import { InterestsService } from './interests.service';
import {
  InterestSignalsService,
  INTEREST_SIGNAL_QUEUE,
} from './interest-signals.service';
import { InterestSignalProcessor } from './interest-signal.processor';
import { InterestsController } from './interests.controller';
import { AdminInterestsController } from './admin-interests.controller';

@Module({
  imports: [
    MikroOrmModule.forFeature([Interest, UserInterest, InterestSignal]),
    BullModule.registerQueue({ name: INTEREST_SIGNAL_QUEUE }),
  ],
  controllers: [InterestsController, AdminInterestsController],
  providers: [InterestsService, InterestSignalsService, InterestSignalProcessor],
  exports: [InterestsService, InterestSignalsService],
})
export class InterestsModule {}
