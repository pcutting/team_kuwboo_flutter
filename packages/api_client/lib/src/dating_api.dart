import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Dating module endpoints. Backend routes are guarded by
/// `JwtAuthGuard` + `DatingAgeGuard` — calls will 403 if the current user
/// is under 18 or has no verified date of birth, and the UI should treat
/// that as an onboarding blocker rather than a transient error.
///
/// See `apps/api/src/modules/dating/dating.controller.ts` (PR #98).
/// The service is currently stubbed (returns empty collections) while the
/// real dating logic is scoped in a separate SOW, so the shapes here map
/// the contract without assuming populated data.
class DatingApi {
  DatingApi(this._client);

  final KuwbooApiClient _client;

  /// `GET /dating/discover` — swipe-stack candidates for the card screen.
  ///
  /// Backend responds with `{items, nextCursor, hasMore}`. Items are modelled
  /// as [Content] rows (the dating module reuses the Content STI table with
  /// `moduleKey = dating`), so the existing Content + FeedCreator freezed
  /// shape serves both the card and the expanded-profile screens.
  Future<DatingDiscoverPage> discover({String? cursor}) async {
    final response = await _client.dio.get(
      '/dating/discover',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final rawItems = (data['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return DatingDiscoverPage(
      items: rawItems.map(Content.fromJson).toList(),
      nextCursor: data['nextCursor'] as String?,
      hasMore: data['hasMore'] as bool? ?? false,
    );
  }

  /// `GET /dating/matches` — active mutual matches for the current user.
  ///
  /// The stub returns `{matches: []}`. We surface raw maps until the real
  /// match shape (with peer user summary + last-message preview) lands
  /// alongside the full dating SOW.
  Future<List<Map<String, dynamic>>> matches() async {
    final response = await _client.dio.get('/dating/matches');
    final data = response.data['data'] as Map<String, dynamic>;
    final raw = (data['matches'] as List<dynamic>? ?? const []);
    return raw.cast<Map<String, dynamic>>();
  }

  /// `GET /dating/likes` — likes received by the current user.
  ///
  /// The stub returns `{likes: []}`. Same raw-map treatment as [matches]
  /// until the backing shape is finalised.
  Future<List<Map<String, dynamic>>> likes() async {
    final response = await _client.dio.get('/dating/likes');
    final data = response.data['data'] as Map<String, dynamic>;
    final raw = (data['likes'] as List<dynamic>? ?? const []);
    return raw.cast<Map<String, dynamic>>();
  }
}

/// Page of dating discover results. Mirrors the backend envelope
/// `{items, nextCursor, hasMore}` with items typed as [Content].
class DatingDiscoverPage {
  const DatingDiscoverPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<Content> items;
  final String? nextCursor;
  final bool hasMore;
}
