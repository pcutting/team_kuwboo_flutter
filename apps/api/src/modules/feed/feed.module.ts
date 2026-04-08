import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { FeedService } from './feed.service';
import { FeedController } from './feed.controller';
import { FeedGateway } from './feed.gateway';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';
import { ConnectionsModule } from '../connections/connections.module';

@Module({
  imports: [
    ConnectionsModule,
    JwtModule.register({}),
  ],
  controllers: [FeedController],
  providers: [WsAuthGuard, FeedGateway, FeedService],
  exports: [FeedService, FeedGateway],
})
export class FeedModule {}
