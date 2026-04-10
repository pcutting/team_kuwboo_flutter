import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Session } from './entities/session.entity';
import { SessionsService } from './sessions.service';
import { RealtimeModule } from '../realtime/realtime.module';

@Module({
  imports: [MikroOrmModule.forFeature([Session]), RealtimeModule],
  providers: [SessionsService],
  exports: [SessionsService],
})
export class SessionsModule {}
