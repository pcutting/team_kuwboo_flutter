import 'package:dio/dio.dart';

import 'feed_models.dart';

/// Thin wrapper over the feed/content/marketplace/yoyo endpoints.
///
/// Construct with a [Dio] already pointed at the API base URL. The bearer
/// token is attached by the interceptor in `providers/api_provider.dart`.
class FeedApi {
  FeedApi(this._dio);

  final Dio _dio;

  /// `GET /feed?tab=video` — personalized feed filtered to one content type.
  Future<FeedPage> getFeed({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/feed',
      queryParameters: {
        'tab': tab,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return FeedPage.fromJson(res.data ?? const {});
  }

  /// `GET /feed/discover?tab=...` — returns a flat array of items.
  Future<List<FeedItem>> getDiscover({
    required String tab,
    int limit = 20,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/feed/discover',
      queryParameters: {'tab': tab, 'limit': limit},
    );
    return (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FeedItem.fromJson)
        .toList(growable: false);
  }

  /// `GET /feed/trending?tab=...` — flat array.
  Future<List<FeedItem>> getTrending({
    required String tab,
    int limit = 20,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/feed/trending',
      queryParameters: {'tab': tab, 'limit': limit},
    );
    return (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FeedItem.fromJson)
        .toList(growable: false);
  }

  /// `GET /feed/following?tab=...` — paginated.
  Future<FeedPage> getFollowing({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/feed/following',
      queryParameters: {
        'tab': tab,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return FeedPage.fromJson(res.data ?? const {});
  }

  /// `GET /products` — marketplace listings. Returns `{ items, nextCursor }`.
  Future<FeedPage> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
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
    final data = res.data ?? const <String, dynamic>{};
    // `/products` doesn't return `hasMore`; infer from the presence of a cursor.
    final items = (data['items'] as List?) ?? const [];
    return FeedPage(
      items: items
          .whereType<Map<String, dynamic>>()
          .map(FeedItem.fromJson)
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
      hasMore: data['nextCursor'] != null,
    );
  }

  /// `GET /products/deals` — same shape as `/products`.
  Future<FeedPage> getDeals({String? cursor, int limit = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/products/deals',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = res.data ?? const <String, dynamic>{};
    final items = (data['items'] as List?) ?? const [];
    return FeedPage(
      items: items
          .whereType<Map<String, dynamic>>()
          .map(FeedItem.fromJson)
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
      hasMore: data['nextCursor'] != null,
    );
  }

  /// `GET /products/:id` — single product detail.
  Future<FeedItem> getProductDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/products/$id');
    return FeedItem.fromJson(res.data ?? const {});
  }

  /// `GET /content/:id` — single content item detail.
  Future<FeedItem> getContentDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/content/$id');
    return FeedItem.fromJson(res.data ?? const {});
  }

  /// `GET /yoyo/nearby?lat=..&lng=..&radius=..`
  Future<List<NearbyUser>> getYoyoNearby({
    required double lat,
    required double lng,
    int? radiusKm,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/yoyo/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );
    return (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(NearbyUser.fromJson)
        .toList(growable: false);
  }
}
