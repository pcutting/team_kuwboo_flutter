import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Comment endpoints.
class CommentsApi {
  CommentsApi(this._client);

  final KuwbooApiClient _client;

  /// Create a comment on a content item.
  Future<Comment> createComment({
    required String contentId,
    required String text,
    String? parentCommentId,
  }) async {
    final response = await _client.dio.post(
      '/content/$contentId/comments',
      data: {
        'text': text,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
    return _client.unwrap(response, Comment.fromJson);
  }

  /// Get paginated comments for a content item.
  Future<List<Comment>> getComments({
    required String contentId,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/content/$contentId/comments',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrapList(response, Comment.fromJson);
  }

  /// Like a comment. Returns true if now liked.
  Future<bool> likeComment(String commentId) async {
    final response = await _client.dio.post('/comments/$commentId/like');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['liked'] as bool;
  }

  /// Delete a comment.
  Future<void> deleteComment(String commentId) async {
    await _client.dio.delete('/comments/$commentId');
  }
}
