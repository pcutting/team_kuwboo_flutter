import 'api_client.dart';

/// Content interaction endpoints (likes, saves, views, shares).
class InteractionsApi {
  InteractionsApi(this._client);

  final KuwbooApiClient _client;

  /// Toggle a like on content. Returns true if now liked, false if unliked.
  Future<bool> toggleLike(String contentId) async {
    final response = await _client.dio.post('/content/$contentId/like');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['liked'] as bool;
  }

  /// Toggle a save/bookmark on content.
  Future<bool> toggleSave(String contentId) async {
    final response = await _client.dio.post('/content/$contentId/save');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['saved'] as bool;
  }

  /// Log a view event for content.
  Future<void> logView(String contentId) async {
    await _client.dio.post('/content/$contentId/view');
  }

  /// Log a share event for content.
  Future<void> logShare(String contentId) async {
    await _client.dio.post('/content/$contentId/share');
  }

  /// Get the current user's interaction state for a content item.
  Future<Map<String, bool>> getUserInteractions(String contentId) async {
    final response =
        await _client.dio.get('/content/$contentId/interactions');
    final data = response.data['data'] as Map<String, dynamic>;
    return {
      'liked': data['liked'] as bool? ?? false,
      'saved': data['saved'] as bool? ?? false,
    };
  }
}
