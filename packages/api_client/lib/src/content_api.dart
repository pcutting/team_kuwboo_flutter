import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Content CRUD endpoints.
class ContentApi {
  ContentApi(this._client);

  final KuwbooApiClient _client;

  /// Create a video content item.
  Future<Video> createVideo({
    required String videoUrl,
    required int durationSeconds,
    String? thumbnailUrl,
    String? caption,
  }) async {
    final response = await _client.dio.post(
      '/content/video',
      data: {
        'videoUrl': videoUrl,
        'durationSeconds': durationSeconds,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (caption != null) 'caption': caption,
      },
    );
    return _client.unwrap(response, Video.fromJson);
  }

  /// Create a text post.
  Future<Post> createPost({
    required String text,
    PostSubType subType = PostSubType.standard,
  }) async {
    final response = await _client.dio.post(
      '/content/post',
      data: {
        'text': text,
        'subType': subType.value,
      },
    );
    return _client.unwrap(response, Post.fromJson);
  }

  /// Get a single content item by ID.
  Future<Content> getContent(String id) async {
    final response = await _client.dio.get('/content/$id');
    return _client.unwrap(response, Content.fromJson);
  }

  /// Hide content (soft-delete by owner).
  Future<void> hideContent(String id) async {
    await _client.dio.patch('/content/$id/hide');
  }

  /// Delete content (hard-delete, admin or owner).
  Future<void> deleteContent(String id) async {
    await _client.dio.delete('/content/$id');
  }
}
