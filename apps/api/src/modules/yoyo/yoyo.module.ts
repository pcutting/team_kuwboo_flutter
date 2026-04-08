import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { YoyoSettings } from './entities/yoyo-settings.entity';
import { YoyoOverride } from './entities/yoyo-override.entity';
import { Wave } from './entities/wave.entity';
import { Thread } from '../messaging/entities/thread.entity';
import { ThreadParticipant } from '../messaging/entities/thread-participant.entity';
import { YoyoService } from './yoyo.service';
import { YoyoController } from './yoyo.controller';
import { ProximityGateway } from './proximity.gateway';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';

@Module({
  imports: [
    MikroOrmModule.forFeature([
      YoyoSettings,
      YoyoOverride,
      Wave,
      Thread,
      ThreadParticipant,
    ]),
    JwtModule.register({}),
  ],
  controllers: [YoyoController],
  providers: [WsAuthGuard, ProximityGateway, YoyoService],
  exports: [ProximityGateway, YoyoService],
})
export class YoyoModule {}
