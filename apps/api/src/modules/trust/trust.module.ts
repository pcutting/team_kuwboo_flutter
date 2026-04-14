import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { TrustSignal } from './entities/trust-signal.entity';
import { TrustService } from './trust.service';

@Module({
  imports: [MikroOrmModule.forFeature([TrustSignal])],
  providers: [TrustService],
  exports: [TrustService],
})
export class TrustModule {}
