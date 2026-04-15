import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Content CRUD + interest-tag endpoints.
///
/// Mirrors the canonical backend `ContentController` (9 routes, STI-aware).
/// See `apps/api/src/modules/content/content.controller.ts` and
/// `admin-content-interest-tags.controller.ts`.
///
/// STI note: every response row is a [Content] with `type` acting as the
/// Single-Table-Inheritance discriminator (VIDEO / PRODUCT / POST / EVENT /
/// WANTED_AD). Subtype-specific fields (`videoUrl`, `text`, etc.) are
/// surfaced as optional fields on the shared [Content] model.
class ContentApi {
  ContentApi(this._client);

  final KuwbooApiClient _client;

  // ─── Create ─────────────────────────────────────────────────────────

  /// POST `/content/videos` — create a video content item.
  /// Returns the STI-discriminated [Content] row (type = VIDEO).
  Future<Content> createVideo(CreateVideoDto dto) async {
    final response = await _client.dio.post(
      '/content/videos',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Content.fromJson);
  }

  /// POST `/content/posts` — create a text post.
  /// Returns the STI-discriminated [Content] row (type = POST).
  Future<Content> createPost(CreatePostDto dto) async {
    final response = await _client.dio.post(
      '/content/posts',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Content.fromJson);
  }

  // ─── Read ───────────────────────────────────────────────────────────

  /// GET `/content/:id` (public).
  Future<Content> getById(String id) async {
    final response = await _client.dio.get('/content/$id');
    return _client.unwrap(response, Content.fromJson);
  }

  // ─── Moderation / lifecycle ─────────────────────────────────────────

  /// PATCH `/content/:id/hide` — creator or moderator sets status = HIDDEN.
  Future<Content> hide(String id) async {
    final response = await _client.dio.patch('/content/$id/hide');
    return _client.unwrap(response, Content.fromJson);
  }

  /// PATCH `/content/:id/unhide` — restore to ACTIVE.
  Future<Content> unhide(String id) async {
    final response = await _client.dio.patch('/content/$id/unhide');
    return _client.unwrap(response, Content.fromJson);
  }

  /// DELETE `/content/:id` — soft delete (creator or admin).
  Future<void> delete(String id) async {
    await _client.dio.delete('/content/$id');
  }

  // ─── Interest tags ──────────────────────────────────────────────────

  /// GET `/content/:id/interest-tags` (public).
  Future<List<ContentInterestTag>> getInterestTags(String id) async {
    final response = await _client.dio.get('/content/$id/interest-tags');
    // Backend shape: `{ data: { interest_tags: [...] } }`.
    final wrapped = response.data as Map<String, dynamic>;
    final inner = wrapped['data'] as Map<String, dynamic>;
    final list = (inner['interest_tags'] as List<dynamic>? ?? <dynamic>[]);
    return list
        .map((e) => ContentInterestTag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST `/content/:id/interest-tags` — creator-only replace-all.
  /// Returns the new interest ids.
  Future<List<String>> setInterestTags(
    String id,
    SetInterestTagsDto dto,
  ) async {
    final response = await _client.dio.post(
      '/content/$id/interest-tags',
      data: dto.toJson(),
    );
    final wrapped = response.data as Map<String, dynamic>;
    final inner = wrapped['data'] as Map<String, dynamic>;
    return (inner['interest_ids'] as List<dynamic>).cast<String>();
  }

  /// POST `/admin/content/:id/interest-tags` — admin-only replace-all.
  /// Bypasses the creator-ownership check.
  Future<List<String>> adminSetInterestTags(
    String id,
    SetInterestTagsDto dto,
  ) async {
    final response = await _client.dio.post(
      '/admin/content/$id/interest-tags',
      data: dto.toJson(),
    );
    final wrapped = response.data as Map<String, dynamic>;
    final inner = wrapped['data'] as Map<String, dynamic>;
    return (inner['interest_ids'] as List<dynamic>).cast<String>();
  }
}
