import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { BotProfile } from './entities/bot-profile.entity';
import { BotActivityLog } from './entities/bot-activity-log.entity';
import { BotsService } from './bots.service';
import { BotEngineService } from './bot-engine.service';
import { BotMovementService } from './bot-movement.service';
import { BotSchedulerService } from './bot-scheduler.service';
import { BotActionProcessor } from './bot-action.processor';
import { BotSimulationBootstrap } from './bot-simulation-bootstrap.service';
import { BotAdminController } from './bot-admin.controller';
import { ContentModule } from '../content/content.module';
import { InteractionsModule } from '../interactions/interactions.module';
import { CommentsModule } from '../comments/comments.module';
import { ConnectionsModule } from '../connections/connections.module';
import { YoyoModule } from '../yoyo/yoyo.module';
import { MessagingModule } from '../messaging/messaging.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([BotProfile, BotActivityLog]),
    BullModule.registerQueue({ name: 'bot-actions' }),
    ContentModule,
    InteractionsModule,
    CommentsModule,
    ConnectionsModule,
    YoyoModule,
    MessagingModule,
  ],
  controllers: [BotAdminController],
  providers: [
    BotsService,
    BotEngineService,
    BotMovementService,
    BotSchedulerService,
    BotActionProcessor,
    BotSimulationBootstrap,
  ],
  exports: [BotsService],
})
export class BotsModule {}
