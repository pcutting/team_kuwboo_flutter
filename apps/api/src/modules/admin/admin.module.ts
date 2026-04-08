import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { AdminAuditService } from './admin-audit.service';
import { AdminAnalyticsService } from './admin-analytics.service';
import { AdminAuditLog } from './entities/admin-audit-log.entity';
import { SessionsModule } from '../sessions/sessions.module';
import { ContentModule } from '../content/content.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([AdminAuditLog]),
    BullModule.registerQueue({ name: 'bot-actions' }),
    SessionsModule,
    ContentModule,
  ],
  controllers: [AdminController],
  providers: [AdminService, AdminAuditService, AdminAnalyticsService],
})
export class AdminModule {}
