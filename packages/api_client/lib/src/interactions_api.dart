import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Content interaction endpoints (5 routes): likes, saves, views, shares,
/// and the combined state projection.
class InteractionsApi {
  InteractionsApi(this._client);

  final KuwbooApiClient _client;

  /// `POST /content/:id/like` — toggle like; returns new state + count.
  Future<LikeResponse> likeContent(String id) async {
    final response = await _client.dio.post('/content/$id/like');
    return _client.unwrap(response, LikeResponse.fromJson);
  }

  /// `POST /content/:id/save` — toggle save/bookmark.
  Future<SaveResponse> saveContent(String id) async {
    final response = await _client.dio.post('/content/$id/save');
    return _client.unwrap(response, SaveResponse.fromJson);
  }

  /// `POST /content/:id/view` — log a view event (fire-and-forget).
  Future<void> logView(String id) async {
    await _client.dio.post('/content/$id/view');
  }

  /// `POST /content/:id/share` — log a share event.
  Future<void> logShare(String id) async {
    await _client.dio.post('/content/$id/share');
  }

  /// `GET /content/:id/interactions` — current user's state + aggregate
  /// interaction counts for a content item.
  Future<InteractionState> getInteractionState(String id) async {
    final response = await _client.dio.get('/content/$id/interactions');
    return _client.unwrap(response, InteractionState.fromJson);
  }
}
