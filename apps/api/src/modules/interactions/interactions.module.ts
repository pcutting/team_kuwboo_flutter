import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { InteractionState } from './entities/interaction-state.entity';
import { InteractionEvent } from './entities/interaction-event.entity';
import { InteractionsService } from './interactions.service';
import { InteractionsController } from './interactions.controller';

@Module({
  imports: [MikroOrmModule.forFeature([InteractionState, InteractionEvent])],
  controllers: [InteractionsController],
  providers: [InteractionsService],
  exports: [InteractionsService],
})
export class InteractionsModule {}
