import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Feed read endpoints — mirrors the four routes under `/feed` on the
/// NestJS backend (see `apps/api/src/modules/feed/feed.controller.ts`).
///
/// All methods return [FeedResponse] from `kuwboo_models`. Responses are
/// unwrapped from the backend's `{data: …}` envelope by [KuwbooApiClient].
///
/// `tab` is a free-form string on the backend — the documented values are
/// `home` (default), `video`, `social`, `shop`. Pass whatever the backend
/// accepts; we intentionally avoid an enum here so new tabs added on the
/// server don't require a client release.
class FeedApi {
  FeedApi(this._client);

  final KuwbooApiClient _client;

  /// GET `/feed` — main feed with cursor pagination.
  ///
  /// Requires a Bearer token. `tab` defaults to `home`.
  Future<FeedResponse> getHome({
    String tab = 'home',
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/feed',
      queryParameters: {
        'tab': tab,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// GET `/feed/following` — content from users the current user follows.
  ///
  /// `moduleScope` narrows to a specific follow bucket (e.g. `video_making`).
  Future<FeedResponse> getFollowing({
    String tab = 'home',
    String? cursor,
    int limit = 20,
    String? moduleScope,
  }) async {
    final response = await _client.dio.get(
      '/feed/following',
      queryParameters: {
        'tab': tab,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (moduleScope != null) 'moduleScope': moduleScope,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// GET `/feed/trending` — public, no auth required (though the Dio
  /// interceptor will still attach a Bearer token if one is present — the
  /// backend ignores it for this route).
  ///
  /// Backend returns a flat `Content[]`; we wrap it into [FeedResponse]
  /// with `hasMore: false` so callers get a single shape across all four
  /// feeds.
  Future<FeedResponse> getTrending({
    String tab = 'home',
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/feed/trending',
      queryParameters: {
        'tab': tab,
        'limit': limit,
      },
    );
    final items = _client.unwrapList(response, Content.fromJson);
    return FeedResponse(items: items, hasMore: false);
  }

  /// GET `/feed/discover` — personalized discovery. Requires Bearer token.
  ///
  /// Backend returns a flat `Content[]` (shuffled, sliced to [limit]); we
  /// wrap into [FeedResponse] for shape parity with the paginated feeds.
  Future<FeedResponse> getDiscover({
    String tab = 'home',
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/feed/discover',
      queryParameters: {
        'tab': tab,
        'limit': limit,
      },
    );
    final items = _client.unwrapList(response, Content.fromJson);
    return FeedResponse(items: items, hasMore: false);
  }
}
