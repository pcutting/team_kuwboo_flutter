import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Host-app provides this override via `ProviderScope(overrides: [...])`.
/// Shared across feature modules by convention — coordinator dedupes.
final apiClientProvider = Provider<KuwbooApiClient>((ref) {
  throw UnimplementedError(
    'apiClientProvider must be overridden at the ProviderScope root.',
  );
});

final marketplaceApiProvider = Provider<MarketplaceApi>(
  (ref) => MarketplaceApi(ref.watch(apiClientProvider)),
);

// ─── Products / Browse ────────────────────────────────────────────────

/// Query args for [shopBrowseProvider]. Keyed by value-equality.
class ShopFilters {
  const ShopFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
  });

  final String? category;
  final int? minPrice;
  final int? maxPrice;
  final String? condition;

  @override
  bool operator ==(Object o) =>
      o is ShopFilters &&
      o.category == category &&
      o.minPrice == minPrice &&
      o.maxPrice == maxPrice &&
      o.condition == condition;

  @override
  int get hashCode => Object.hash(category, minPrice, maxPrice, condition);
}

final shopBrowseProvider =
    FutureProvider.autoDispose.family<ProductPage, ShopFilters>(
  (ref, f) => ref.watch(marketplaceApiProvider).listProducts(
        category: f.category,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        condition: f.condition,
      ),
);

final shopDealsProvider = FutureProvider.autoDispose<ProductPage>(
  (ref) => ref.watch(marketplaceApiProvider).getDeals(),
);

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>(
  (ref, id) => ref.watch(marketplaceApiProvider).getProduct(id),
);

// ─── Auctions ─────────────────────────────────────────────────────────

final auctionDetailProvider =
    FutureProvider.autoDispose.family<AuctionWithBids, String>(
  (ref, id) => ref.watch(marketplaceApiProvider).getAuction(id),
);

// ─── Seller ───────────────────────────────────────────────────────────

final sellerRatingsProvider =
    FutureProvider.autoDispose.family<SellerRatingPage, String>(
  (ref, sellerId) =>
      ref.watch(marketplaceApiProvider).getSellerRatings(sellerId),
);
