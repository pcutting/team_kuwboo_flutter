import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Thread } from './entities/thread.entity';
import { ThreadParticipant } from './entities/thread-participant.entity';
import { Message } from './entities/message.entity';
import { MessagingService } from './messaging.service';
import { MessagingController } from './messaging.controller';
import { ChatGateway } from './chat.gateway';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Thread, ThreadParticipant, Message]),
    JwtModule.register({}),
    UsersModule,
  ],
  controllers: [MessagingController],
  providers: [WsAuthGuard, ChatGateway, MessagingService],
  exports: [ChatGateway, MessagingService],
})
export class MessagingModule {}
