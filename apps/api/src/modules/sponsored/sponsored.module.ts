import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { SponsoredCampaign } from './entities/sponsored-campaign.entity';
import { SponsoredService } from './sponsored.service';
import { SponsoredController } from './sponsored.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([SponsoredCampaign]),
    UsersModule,
  ],
  controllers: [SponsoredController],
  providers: [SponsoredService],
  exports: [SponsoredService],
})
export class SponsoredModule {}
