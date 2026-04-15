import { Module } from '@nestjs/common';
import { DatingController } from './dating.controller';
import { DatingService } from './dating.service';

@Module({
  controllers: [DatingController],
  providers: [DatingService],
  exports: [DatingService],
})
export class DatingModule {}
