import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { EntityManager, raw } from '@mikro-orm/postgresql';
import { Product } from '../content/entities/product.entity';
import { Auction } from './entities/auction.entity';
import { Bid } from './entities/bid.entity';
import { SellerRating } from './entities/seller-rating.entity';
import { User } from '../users/entities/user.entity';
import { Content } from '../content/entities/content.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { CreateAuctionDto } from './dto/create-auction.dto';
import { PlaceBidDto } from './dto/place-bid.dto';
import { CreateSellerRatingDto } from './dto/create-seller-rating.dto';
import {
  ContentType,
  ContentStatus,
  AuctionStatus,
  ProductCondition,
} from '../../common/enums';

@Injectable()
export class MarketplaceService {
  constructor(private readonly em: EntityManager) {}

  async createProduct(user: User, dto: CreateProductDto): Promise<Product> {
    const product = this.em.create(Product, {
      type: ContentType.PRODUCT,
      creator: user,
      title: dto.title,
      description: dto.description,
      priceCents: dto.priceCents,
      currency: dto.currency ?? 'GBP',
      condition: dto.condition,
      isDeal: dto.isDeal ?? false,
      originalPriceCents: dto.originalPriceCents,
      visibility: dto.visibility,
      status: ContentStatus.ACTIVE,
      location:
        dto.latitude !== undefined && dto.longitude !== undefined
          ? { latitude: dto.latitude, longitude: dto.longitude }
          : undefined,
      locationName: dto.locationName,
    } as any);

    await this.em.flush();
    return product;
  }

  async getProducts(filters: {
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    condition?: ProductCondition;
    cursor?: string;
    limit?: number;
  }): Promise<{ items: Product[]; nextCursor?: string }> {
    const limit = filters.limit ?? 20;
    const where: Record<string, any> = {
      type: ContentType.PRODUCT,
      status: ContentStatus.ACTIVE,
    };

    if (filters.condition) where.condition = filters.condition;
    if (filters.minPrice !== undefined) where.priceCents = { $gte: filters.minPrice };
    if (filters.maxPrice !== undefined) {
      where.priceCents = { ...where.priceCents, $lte: filters.maxPrice };
    }
    if (filters.cursor) where.createdAt = { $lt: new Date(filters.cursor) };

    const items = await this.em.find(Product, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['creator'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
    };
  }

  async getDeals(cursor?: string, limit = 20): Promise<{ items: Product[]; nextCursor?: string }> {
    const where: Record<string, any> = {
      type: ContentType.PRODUCT,
      status: ContentStatus.ACTIVE,
      isDeal: true,
    };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(Product, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['creator'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
    };
  }

  async getSellerProducts(
    sellerId: string,
    cursor?: string,
    limit = 20,
  ): Promise<{ items: Product[]; nextCursor?: string }> {
    const where: Record<string, any> = {
      type: ContentType.PRODUCT,
      status: ContentStatus.ACTIVE,
      creator: sellerId,
    };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(Product, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['creator'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
    };
  }

  async getProductById(id: string): Promise<Product> {
    const product = await this.em.findOne(Product, { id, type: ContentType.PRODUCT }, { populate: ['creator'] });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async createAuction(user: User, dto: CreateAuctionDto): Promise<Auction> {
    const product = await this.em.findOne(Content, {
      id: dto.productId,
      type: ContentType.PRODUCT,
      creator: user,
    });
    if (!product) throw new NotFoundException('Product not found or not owned by user');

    const existing = await this.em.findOne(Auction, {
      product,
      status: { $in: [AuctionStatus.SCHEDULED, AuctionStatus.ACTIVE] },
    });
    if (existing) throw new ConflictException('Active auction already exists for this product');

    const auction = this.em.create(Auction, {
      product,
      startPriceCents: dto.startPriceCents,
      currentPriceCents: dto.startPriceCents,
      minIncrementCents: dto.minIncrementCents ?? 100,
      startsAt: new Date(dto.startsAt),
      endsAt: new Date(dto.endsAt),
      antiSnipeMinutes: dto.antiSnipeMinutes ?? 2,
    } as any);

    await this.em.flush();
    return auction;
  }

  async getAuction(id: string): Promise<Auction> {
    const auction = await this.em.findOne(Auction, { id }, { populate: ['product'] });
    if (!auction) throw new NotFoundException('Auction not found');
    return auction;
  }

  async getAuctionWithBids(id: string): Promise<{ auction: Auction; bids: Bid[] }> {
    const auction = await this.getAuction(id);
    const bids = await this.em.find(
      Bid,
      { auction },
      { orderBy: { amountCents: 'DESC' }, populate: ['bidder'] },
    );
    return { auction, bids };
  }

  async placeBid(user: User, auctionId: string, dto: PlaceBidDto): Promise<Bid> {
    return this.em.transactional(async (txEm) => {
      const auction = await txEm.findOne(
        Auction,
        { id: auctionId, status: AuctionStatus.ACTIVE },
        { lockMode: 2 }, // PESSIMISTIC_WRITE
      );
      if (!auction) throw new NotFoundException('Active auction not found');

      if (auction.product && (auction.product as any).creator === user.id) {
        throw new BadRequestException('Cannot bid on your own auction');
      }

      const minBid = auction.currentPriceCents + auction.minIncrementCents;
      if (dto.amountCents < minBid) {
        throw new BadRequestException(
          `Bid must be at least ${minBid} cents (current: ${auction.currentPriceCents} + increment: ${auction.minIncrementCents})`,
        );
      }

      const bid = txEm.create(Bid, {
        auction,
        bidder: user,
        amountCents: dto.amountCents,
      } as any);

      auction.currentPriceCents = dto.amountCents;

      // Anti-snipe: extend auction if bid placed within antiSnipeMinutes of end
      const now = new Date();
      const msUntilEnd = auction.endsAt.getTime() - now.getTime();
      const antiSnipeMs = auction.antiSnipeMinutes * 60 * 1000;
      if (msUntilEnd < antiSnipeMs) {
        auction.endsAt = new Date(now.getTime() + antiSnipeMs);
      }

      await txEm.flush();
      return bid;
    });
  }

  async rateSeller(user: User, sellerId: string, dto: CreateSellerRatingDto): Promise<SellerRating> {
    const seller = await this.em.findOne(User, { id: sellerId });
    if (!seller) throw new NotFoundException('Seller not found');

    const product = await this.em.findOne(Content, { id: dto.productId, type: ContentType.PRODUCT });
    if (!product) throw new NotFoundException('Product not found');

    const existing = await this.em.findOne(SellerRating, { buyer: user, product });
    if (existing) throw new ConflictException('Already rated this product');

    const rating = this.em.create(SellerRating, {
      seller,
      buyer: user,
      product,
      rating: dto.rating,
      review: dto.review,
    } as any);

    await this.em.flush();
    return rating;
  }

  async getSellerRatings(
    sellerId: string,
    cursor?: string,
    limit = 20,
  ): Promise<{ items: SellerRating[]; nextCursor?: string; averageRating: number }> {
    const where: Record<string, any> = { seller: sellerId };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(SellerRating, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['buyer', 'product'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    // Calculate average
    const allRatings = await this.em.find(SellerRating, { seller: sellerId });
    const avg =
      allRatings.length > 0
        ? allRatings.reduce((sum, r) => sum + r.rating, 0) / allRatings.length
        : 0;

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
      averageRating: Math.round(avg * 10) / 10,
    };
  }
}
