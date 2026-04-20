import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Base URL for the Kuwboo API. Override in app bootstrap via
/// `ProviderScope(overrides: [apiBaseUrlProvider.overrideWithValue(...)])`.
final apiBaseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'apiBaseUrlProvider must be overridden at app startup with the API base URL.',
  );
});

/// Shared [KuwbooApiClient] — holds the Dio instance + auth interceptor.
final kuwbooApiClientProvider = Provider<KuwbooApiClient>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return KuwbooApiClient(baseUrl: baseUrl);
});

// ─── API surface providers ──────────────────────────────────────────────

final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(kuwbooApiClientProvider)),
);

final contentApiProvider = Provider<ContentApi>(
  (ref) => ContentApi(ref.watch(kuwbooApiClientProvider)),
);

final interactionsApiProvider = Provider<InteractionsApi>(
  (ref) => InteractionsApi(ref.watch(kuwbooApiClientProvider)),
);

final commentsApiProvider = Provider<CommentsApi>(
  (ref) => CommentsApi(ref.watch(kuwbooApiClientProvider)),
);

final connectionsApiProvider = Provider<ConnectionsApi>(
  (ref) => ConnectionsApi(ref.watch(kuwbooApiClientProvider)),
);

/// In-session set of creator user ids the signed-in user has tapped "Follow"
/// for. Used by the Stumble cards to switch their button from "Follow" →
/// "Following" without waiting for a re-fetch of the discovery feed. Cleared
/// on sign-out (provider is refreshed with the rest of the auth scope).
///
/// This is a UI optimism layer, not a source of truth — the real membership
/// lives in the `connections` table server-side.
final followedCreatorsProvider = StateProvider<Set<String>>((_) => <String>{});

// ─── Social feed ────────────────────────────────────────────────────────

/// The main social tab feed — hits `/feed?tab=social`.
final socialFeedProvider = FutureProvider.autoDispose<FeedResponse>((ref) {
  final api = ref.watch(feedApiProvider);
  return api.getHome(tab: 'social');
});

/// "Stumble" discovery feed — hits `/feed/discover?tab=social`.
/// Backend returns a flat array; `FeedApi.getDiscover` wraps it in a
/// [FeedResponse] with `hasMore: false`.
final socialStumbleProvider = FutureProvider.autoDispose<FeedResponse>((ref) {
  final api = ref.watch(feedApiProvider);
  return api.getDiscover(tab: 'social');
});

/// Following feed (posts from users you follow).
final socialFollowingProvider = FutureProvider.autoDispose<FeedResponse>((ref) {
  final api = ref.watch(feedApiProvider);
  return api.getFollowing(tab: 'social');
});

// ─── Friends list (OFFSET pagination) ───────────────────────────────────

/// Page of connections. Backend uses **offset pagination**, not cursor —
/// this is different from feed endpoints.
class FriendsPage {
  const FriendsPage({
    required this.items,
    required this.limit,
    required this.offset,
  });

  final List<Connection> items;
  final int limit;
  final int offset;

  bool get hasMore => items.length >= limit;
  int get nextOffset => offset + items.length;
}

/// Query args for [friendsListProvider].
class FriendsListArgs {
  const FriendsListArgs({
    this.limit = 20,
    this.offset = 0,
    this.following = false,
  });

  final int limit;
  final int offset;

  /// `false` → list followers (default), `true` → list following.
  final bool following;

  @override
  bool operator ==(Object other) =>
      other is FriendsListArgs &&
      other.limit == limit &&
      other.offset == offset &&
      other.following == following;

  @override
  int get hashCode => Object.hash(limit, offset, following);
}

/// Friends list with OFFSET pagination. Hits `/connections/followers` or
/// `/connections/following` with `limit` + `offset` query params.
///
/// The generated [ConnectionsApi] uses `cursor` as the param name, but the
/// backend interprets it as an integer offset string. We bypass that here
/// and call Dio directly to keep the semantics explicit.
final friendsListProvider =
    FutureProvider.autoDispose.family<FriendsPage, FriendsListArgs>(
  (ref, args) async {
    final client = ref.watch(kuwbooApiClientProvider);
    final path =
        args.following ? '/connections/following' : '/connections/followers';
    final response = await client.dio.get(
      path,
      queryParameters: {
        'limit': args.limit,
        'offset': args.offset,
      },
    );
    final items = client.unwrapList(response, Connection.fromJson);
    return FriendsPage(
      items: items,
      limit: args.limit,
      offset: args.offset,
    );
  },
);

// ─── Story viewer ───────────────────────────────────────────────────────

/// Stories are ephemeral content — **no backend `stories` endpoint exists**
/// (checked `apps/api/src/modules/content/content.controller.ts`). Until a
/// stories surface is added, we treat the first N items of the social feed
/// as pseudo-"stories" so the viewer has something to render. [contentId]
/// is unused today but preserved as the family key so callers can pass a
/// specific thread id once the backend exposes one.
final storyThreadProvider =
    FutureProvider.autoDispose.family<List<Content>, String>(
  (ref, contentId) async {
    final feed = await ref.watch(socialFeedProvider.future);
    // Take first 5 posts as the "story thread" placeholder.
    return feed.items.take(5).toList();
  },
);

// ─── Composer ───────────────────────────────────────────────────────────

/// State for the composer submit action.
class ComposerSubmitState {
  const ComposerSubmitState({
    this.isSubmitting = false,
    this.error,
    this.result,
  });

  final bool isSubmitting;
  final Object? error;
  final Content? result;
}

/// Controller for the social composer. Call [submit] to create a post;
/// watch the state to drive the submit button UI.
class SocialComposerController extends StateNotifier<ComposerSubmitState> {
  SocialComposerController(this._contentApi)
      : super(const ComposerSubmitState());

  final ContentApi _contentApi;

  Future<Content?> submit({
    required String text,
    PostSubType subType = PostSubType.standard,
  }) async {
    state = const ComposerSubmitState(isSubmitting: true);
    try {
      final post = await _contentApi.createPost(
        CreatePostDto(text: text, subType: subType),
      );
      state = ComposerSubmitState(result: post);
      return post;
    } catch (e) {
      state = ComposerSubmitState(error: e);
      return null;
    }
  }

  void reset() => state = const ComposerSubmitState();
}

final socialComposerControllerProvider = StateNotifierProvider.autoDispose<
    SocialComposerController, ComposerSubmitState>(
  (ref) => SocialComposerController(ref.watch(contentApiProvider)),
);

// ─── Interactions helpers ───────────────────────────────────────────────

/// Toggle like on a post. Invalidates the social feed so like counts
/// refresh on next rebuild.
Future<bool> togglePostLike(WidgetRef ref, String contentId) async {
  final api = ref.read(interactionsApiProvider);
  final res = await api.likeContent(contentId);
  ref.invalidate(socialFeedProvider);
  return res.liked;
}

/// Toggle save/bookmark on a post.
Future<bool> togglePostSave(WidgetRef ref, String contentId) async {
  final api = ref.read(interactionsApiProvider);
  final res = await api.saveContent(contentId);
  return res.saved;
}

/// Log a view on a post (fire-and-forget semantics — errors swallowed).
Future<void> logPostView(WidgetRef ref, String contentId) async {
  try {
    await ref.read(interactionsApiProvider).logView(contentId);
  } catch (_) {
    // View logging is best-effort; do not surface transport errors.
  }
}

// ─── Comments ───────────────────────────────────────────────────────────

/// Paginated comments for a post.
final postCommentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, String>(
  (ref, contentId) async {
    final api = ref.watch(commentsApiProvider);
    final page = await api.listComments(contentId);
    return page;
  },
);
