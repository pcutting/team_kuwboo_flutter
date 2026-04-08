import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { MarketplaceService } from './marketplace.service';
import { CreateProductDto } from './dto/create-product.dto';
import { CreateAuctionDto } from './dto/create-auction.dto';
import { PlaceBidDto } from './dto/place-bid.dto';
import { CreateSellerRatingDto } from './dto/create-seller-rating.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';
import { ProductCondition } from '../../common/enums';

@ApiTags('marketplace')
@ApiBearerAuth()
@Controller()
export class MarketplaceController {
  constructor(
    private readonly marketplaceService: MarketplaceService,
    private readonly usersService: UsersService,
  ) {}

  @Post('products')
  async createProduct(@CurrentUser('id') userId: string, @Body() dto: CreateProductDto) {
    const user = await this.usersService.findById(userId);
    return this.marketplaceService.createProduct(user, dto);
  }

  @Get('products')
  async getProducts(
    @Query('category') category?: string,
    @Query('minPrice') minPrice?: string,
    @Query('maxPrice') maxPrice?: string,
    @Query('condition') condition?: ProductCondition,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.marketplaceService.getProducts({
      category,
      minPrice: minPrice ? parseInt(minPrice, 10) : undefined,
      maxPrice: maxPrice ? parseInt(maxPrice, 10) : undefined,
      condition,
      cursor,
      limit: limit ? parseInt(limit, 10) : 20,
    });
  }

  @Get('products/deals')
  async getDeals(
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.marketplaceService.getDeals(cursor, limit ? parseInt(limit, 10) : 20);
  }

  @Get('products/:id')
  async getProduct(@Param('id', ParseUUIDPipe) id: string) {
    return this.marketplaceService.getProductById(id);
  }

  @Post('auctions')
  async createAuction(@CurrentUser('id') userId: string, @Body() dto: CreateAuctionDto) {
    const user = await this.usersService.findById(userId);
    return this.marketplaceService.createAuction(user, dto);
  }

  @Get('auctions/:id')
  async getAuction(@Param('id', ParseUUIDPipe) id: string) {
    return this.marketplaceService.getAuctionWithBids(id);
  }

  @Post('auctions/:id/bid')
  async placeBid(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: PlaceBidDto,
  ) {
    const user = await this.usersService.findById(userId);
    return this.marketplaceService.placeBid(user, id, dto);
  }

  @Post('users/:userId/ratings')
  async rateSeller(
    @Param('userId', ParseUUIDPipe) sellerId: string,
    @CurrentUser('id') buyerId: string,
    @Body() dto: CreateSellerRatingDto,
  ) {
    const buyer = await this.usersService.findById(buyerId);
    return this.marketplaceService.rateSeller(buyer, sellerId, dto);
  }

  @Get('users/:userId/ratings')
  async getSellerRatings(
    @Param('userId', ParseUUIDPipe) sellerId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.marketplaceService.getSellerRatings(
      sellerId,
      cursor,
      limit ? parseInt(limit, 10) : 20,
    );
  }
}
