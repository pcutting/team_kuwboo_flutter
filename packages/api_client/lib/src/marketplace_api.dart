import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Marketplace (buy/sell) endpoints.
class MarketplaceApi {
  MarketplaceApi(this._client);

  final KuwbooApiClient _client;

  /// List products with optional filters.
  Future<List<Product>> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
  }) async {
    final response = await _client.dio.get(
      '/marketplace/products',
      queryParameters: {
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (condition != null) 'condition': condition,
      },
    );
    return _client.unwrapList(response, Product.fromJson);
  }

  /// Get a single product by ID.
  Future<Product> getProduct(String id) async {
    final response = await _client.dio.get('/marketplace/products/$id');
    return _client.unwrap(response, Product.fromJson);
  }

  /// Create a new product listing.
  Future<Product> createProduct({
    required String title,
    required String description,
    required int priceCents,
    required String condition,
    String currency = 'GBP',
    bool isDeal = false,
    int? originalPriceCents,
  }) async {
    final response = await _client.dio.post(
      '/marketplace/products',
      data: {
        'title': title,
        'description': description,
        'priceCents': priceCents,
        'condition': condition,
        'currency': currency,
        'isDeal': isDeal,
        if (originalPriceCents != null)
          'originalPriceCents': originalPriceCents,
      },
    );
    return _client.unwrap(response, Product.fromJson);
  }

  /// Get featured deals.
  Future<List<Product>> getDeals() async {
    final response = await _client.dio.get('/marketplace/deals');
    return _client.unwrapList(response, Product.fromJson);
  }

  /// Create an auction for a product.
  Future<Auction> createAuction({
    required String productId,
    required int startPriceCents,
    required int minIncrementCents,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    final response = await _client.dio.post(
      '/marketplace/auctions',
      data: {
        'productId': productId,
        'startPriceCents': startPriceCents,
        'minIncrementCents': minIncrementCents,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
      },
    );
    return _client.unwrap(response, Auction.fromJson);
  }

  /// Get an auction by ID.
  Future<Auction> getAuction(String id) async {
    final response = await _client.dio.get('/marketplace/auctions/$id');
    return _client.unwrap(response, Auction.fromJson);
  }

  /// Place a bid on an auction.
  Future<void> placeBid({
    required String auctionId,
    required int amountCents,
  }) async {
    await _client.dio.post(
      '/marketplace/auctions/$auctionId/bids',
      data: {'amountCents': amountCents},
    );
  }

  /// Rate a seller after a purchase.
  Future<void> rateSeller({
    required String userId,
    required String productId,
    required int rating,
    String? review,
  }) async {
    await _client.dio.post(
      '/marketplace/ratings',
      data: {
        'userId': userId,
        'productId': productId,
        'rating': rating,
        if (review != null) 'review': review,
      },
    );
  }

  /// Get seller ratings.
  Future<List<dynamic>> getSellerRatings(String userId) async {
    final response = await _client.dio.get(
      '/marketplace/ratings/$userId',
    );
    final wrapped = response.data as Map<String, dynamic>;
    return wrapped['data'] as List<dynamic>;
  }
}
