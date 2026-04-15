import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Marketplace (buy/sell + auctions + seller ratings) endpoints.
///
/// Routes match the NestJS `MarketplaceController` exactly — top-level
/// at `/products`, `/auctions`, and `/users/:userId/ratings`. They are
/// NOT prefixed with `/marketplace`.
class MarketplaceApi {
  MarketplaceApi(this._client);

  final KuwbooApiClient _client;

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  /// `POST /products` — create a product listing.
  ///
  /// All optional fields on [CreateProductDto] are supported by passing
  /// them through this method's named parameters.
  Future<Product> createProduct({
    required String title,
    required String description,
    required int priceCents,
    required String condition,
    String currency = 'GBP',
    bool? isDeal,
    int? originalPriceCents,
    String? visibility,
    double? latitude,
    double? longitude,
    String? locationName,
    List<String>? tags,
  }) async {
    final response = await _client.dio.post(
      '/products',
      data: {
        'title': title,
        'description': description,
        'priceCents': priceCents,
        'condition': condition,
        'currency': currency,
        if (isDeal != null) 'isDeal': isDeal,
        if (originalPriceCents != null)
          'originalPriceCents': originalPriceCents,
        if (visibility != null) 'visibility': visibility,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationName != null) 'locationName': locationName,
        if (tags != null) 'tags': tags,
      },
    );
    return _client.unwrap(response, Product.fromJson);
  }

  /// `GET /products` — cursor-paginated product list with optional filters.
  Future<ProductPage> listProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int? limit,
  }) async {
    final response = await _client.dio.get(
      '/products',
      queryParameters: {
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (condition != null) 'condition': condition,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    return _client.unwrap(response, ProductPage.fromJson);
  }

  /// `GET /products/deals` — cursor-paginated deals (products with `isDeal: true`).
  Future<ProductPage> getDeals({String? cursor, int? limit}) async {
    final response = await _client.dio.get(
      '/products/deals',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    return _client.unwrap(response, ProductPage.fromJson);
  }

  /// `GET /products/:id` — fetch a single product.
  Future<Product> getProduct(String id) async {
    final response = await _client.dio.get('/products/$id');
    return _client.unwrap(response, Product.fromJson);
  }

  // ---------------------------------------------------------------------------
  // Auctions
  // ---------------------------------------------------------------------------

  /// `POST /auctions` — create an auction for a product you own.
  Future<Auction> createAuction({
    required String productId,
    required int startPriceCents,
    required DateTime startsAt,
    required DateTime endsAt,
    int? minIncrementCents,
    int? antiSnipeMinutes,
  }) async {
    final response = await _client.dio.post(
      '/auctions',
      data: {
        'productId': productId,
        'startPriceCents': startPriceCents,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        if (minIncrementCents != null) 'minIncrementCents': minIncrementCents,
        if (antiSnipeMinutes != null) 'antiSnipeMinutes': antiSnipeMinutes,
      },
    );
    return _client.unwrap(response, Auction.fromJson);
  }

  /// `GET /auctions/:id` — auction plus its bids (highest bid first).
  Future<AuctionWithBids> getAuction(String id) async {
    final response = await _client.dio.get('/auctions/$id');
    return _client.unwrap(response, AuctionWithBids.fromJson);
  }

  /// `POST /auctions/:id/bid` — place a bid.
  ///
  /// Amount must be at least `currentPriceCents + minIncrementCents`.
  /// Returns the created bid; within anti-snipe window the backend also
  /// extends `endsAt`.
  Future<Bid> placeBid({
    required String auctionId,
    required int amountCents,
  }) async {
    final response = await _client.dio.post(
      '/auctions/$auctionId/bid',
      data: {'amountCents': amountCents},
    );
    return _client.unwrap(response, Bid.fromJson);
  }

  // ---------------------------------------------------------------------------
  // Seller ratings
  // ---------------------------------------------------------------------------

  /// `POST /users/:userId/ratings` — rate a seller for a purchased product.
  Future<SellerRating> rateSeller({
    required String sellerId,
    required String productId,
    required int rating,
    String? review,
  }) async {
    final response = await _client.dio.post(
      '/users/$sellerId/ratings',
      data: {
        'productId': productId,
        'rating': rating,
        if (review != null) 'review': review,
      },
    );
    return _client.unwrap(response, SellerRating.fromJson);
  }

  /// `GET /users/:userId/ratings` — cursor-paginated ratings plus
  /// aggregate `averageRating` summary.
  Future<SellerRatingPage> getSellerRatings(
    String sellerId, {
    String? cursor,
    int? limit,
  }) async {
    final response = await _client.dio.get(
      '/users/$sellerId/ratings',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    return _client.unwrap(response, SellerRatingPage.fromJson);
  }
}
