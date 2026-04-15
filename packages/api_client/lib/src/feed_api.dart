import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Feed, content, marketplace, and yoyo-nearby read endpoints.
///
/// All methods return Freezed models from `kuwboo_models`. Responses are
/// unwrapped from the backend's `{data: …}` envelope by the interceptor
/// chain on [KuwbooApiClient].
class FeedApi {
  FeedApi(this._client);

  final KuwbooApiClient _client;

  // ─── Feed ────────────────────────────────────────────────────────────

  /// Get the main feed for a given tab.
  ///
  /// `tab` is one of `video` | `social` | `shop` | `home` (backend default
  /// is `home`). Pagination via opaque `cursor`.
  Future<FeedResponse> getFeed({
    String? tab,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/feed',
      queryParameters: {
        if (tab != null) 'tab': tab,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// Get the following feed (content from users the current user follows).
  Future<FeedResponse> getFollowing({
    String? tab,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/feed/following',
      queryParameters: {
        if (tab != null) 'tab': tab,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// Get trending content. Backend returns a flat array; wrap it here so
  /// callers get the same [FeedResponse] shape as the paginated endpoints.
  Future<FeedResponse> getTrending({String? tab, int limit = 20}) async {
    final response = await _client.dio.get(
      '/feed/trending',
      queryParameters: {
        if (tab != null) 'tab': tab,
        'limit': limit,
      },
    );
    final items = _client.unwrapList(response, Content.fromJson);
    return FeedResponse(items: items, hasMore: false);
  }

  /// Get the discovery feed. Backend returns a flat array.
  Future<FeedResponse> getDiscover({String? tab, int limit = 20}) async {
    final response = await _client.dio.get(
      '/feed/discover',
      queryParameters: {
        if (tab != null) 'tab': tab,
        'limit': limit,
      },
    );
    final items = _client.unwrapList(response, Content.fromJson);
    return FeedResponse(items: items, hasMore: false);
  }

  // ─── Marketplace ────────────────────────────────────────────────────
  //
  // Live at `/products` (not `/marketplace/products`).

  /// List products with optional filters. Returns `{items, nextCursor}`.
  Future<ProductPage> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/products',
      queryParameters: {
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (condition != null) 'condition': condition,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return _client.unwrap(response, ProductPage.fromJson);
  }

  /// Featured deals — same shape as `/products`.
  Future<ProductPage> getProductDeals({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/products/deals',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return _client.unwrap(response, ProductPage.fromJson);
  }

  /// Single product by id.
  Future<Product> getProductDetail(String id) async {
    final response = await _client.dio.get('/products/$id');
    return _client.unwrap(response, Product.fromJson);
  }

  // ─── Content detail ─────────────────────────────────────────────────

  /// Single content item (video / post) by id.
  Future<Content> getContentDetail(String id) async {
    final response = await _client.dio.get('/content/$id');
    return _client.unwrap(response, Content.fromJson);
  }

  // ─── YoYo nearby ────────────────────────────────────────────────────

  /// Nearby users. Backend accepts `lat` / `lng` / `radius` (km).
  Future<List<NearbyUser>> getYoyoNearby({
    required double lat,
    required double lng,
    int? radiusKm,
  }) async {
    final response = await _client.dio.get(
      '/yoyo/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );
    return _client.unwrapList(response, NearbyUser.fromJson);
  }
}
