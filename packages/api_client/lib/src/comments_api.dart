import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Comment endpoints (4 routes).
class CommentsApi {
  CommentsApi(this._client);

  final KuwbooApiClient _client;

  /// `POST /content/:contentId/comments` — create a comment.
  Future<Comment> createComment(
    String contentId,
    CreateCommentDto dto,
  ) async {
    final response = await _client.dio.post(
      '/content/$contentId/comments',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Comment.fromJson);
  }

  /// `GET /content/:contentId/comments` — cursor-paginated.
  Future<List<Comment>> listComments(
    String contentId, {
    String? cursor,
    int? limit,
  }) async {
    final response = await _client.dio.get(
      '/content/$contentId/comments',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrapList(response, Comment.fromJson);
  }

  /// `POST /comments/:id/like` — toggle like on a comment.
  /// Returns true if now liked.
  Future<bool> likeComment(String id) async {
    final response = await _client.dio.post('/comments/$id/like');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['liked'] as bool;
  }

  /// `DELETE /comments/:id` — delete a comment.
  Future<void> deleteComment(String id) async {
    await _client.dio.delete('/comments/$id');
  }
}
