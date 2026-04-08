import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Product } from '../content/entities/product.entity';
import { Auction } from './entities/auction.entity';
import { Bid } from './entities/bid.entity';
import { SellerRating } from './entities/seller-rating.entity';
import { MarketplaceService } from './marketplace.service';
import { MarketplaceController } from './marketplace.controller';
import { MarketplaceGateway } from './marketplace.gateway';
import { WsAuthGuard } from '../../common/guards/ws-auth.guard';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Product, Auction, Bid, SellerRating]),
    JwtModule.register({}),
    UsersModule,
  ],
  controllers: [MarketplaceController],
  providers: [WsAuthGuard, MarketplaceGateway, MarketplaceService],
  exports: [MarketplaceService, MarketplaceGateway],
})
export class MarketplaceModule {}
