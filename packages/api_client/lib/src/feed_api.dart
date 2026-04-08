import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Feed retrieval endpoints.
class FeedApi {
  FeedApi(this._client);

  final KuwbooApiClient _client;

  /// Get the main feed for a given tab.
  Future<FeedResponse> getFeed({
    required String tab,
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

  /// Get the following feed (content from users the current user follows).
  Future<FeedResponse> getFollowing({String? cursor, int limit = 20}) async {
    final response = await _client.dio.get(
      '/feed/following',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// Get trending content.
  Future<FeedResponse> getTrending({String? cursor, int limit = 20}) async {
    final response = await _client.dio.get(
      '/feed/trending',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }

  /// Get the discovery feed.
  Future<FeedResponse> getDiscover({String? cursor, int limit = 20}) async {
    final response = await _client.dio.get(
      '/feed/discover',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, FeedResponse.fromJson);
  }
}
