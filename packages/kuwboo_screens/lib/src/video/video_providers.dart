import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Root API client provider. The hosting app (kuwboo_shell or test harness)
/// MUST override this with a configured [KuwbooApiClient]. Leaving it at the
/// default throws — there is no mock fallback.
final apiClientProvider = Provider<KuwbooApiClient>((ref) {
  throw UnimplementedError(
    'apiClientProvider must be overridden by the host app with a '
    'configured KuwbooApiClient instance.',
  );
});

final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(apiClientProvider)),
);

final contentApiProvider = Provider<ContentApi>(
  (ref) => ContentApi(ref.watch(apiClientProvider)),
);

final commentsApiProvider = Provider<CommentsApi>(
  (ref) => CommentsApi(ref.watch(apiClientProvider)),
);

final interactionsApiProvider = Provider<InteractionsApi>(
  (ref) => InteractionsApi(ref.watch(apiClientProvider)),
);

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(apiClientProvider)),
);

// ─── Feed ─────────────────────────────────────────────────────────────

/// Which video feed variant to load.
enum VideoFeedKind { forYou, following, trending, discover }

/// Video feed provider. Maps [kind] to the correct FeedApi method with
/// `tab: 'video'` so all results are ContentType.video.
final videoFeedProvider =
    FutureProvider.family<FeedResponse, VideoFeedKind>((ref, kind) async {
  final api = ref.watch(feedApiProvider);
  switch (kind) {
    case VideoFeedKind.forYou:
      return api.getHome(tab: 'video');
    case VideoFeedKind.following:
      return api.getFollowing(tab: 'video');
    case VideoFeedKind.trending:
      return api.getTrending(tab: 'video');
    case VideoFeedKind.discover:
      return api.getDiscover(tab: 'video');
  }
});

// ─── Comments ─────────────────────────────────────────────────────────

/// Paginated comments list for a given content id. UI can `ref.invalidate`
/// this after posting a new comment to refetch.
final videoCommentsProvider =
    FutureProvider.family<List<Comment>, String>((ref, contentId) async {
  final api = ref.watch(commentsApiProvider);
  return api.listComments(contentId);
});

// ─── Creator profile ──────────────────────────────────────────────────

/// Fetch a creator's profile. Currently only supports the authenticated
/// user (`/users/me`) — the backend does not yet expose `/users/{id}`.
/// When it does, swap to a real per-id call.
final creatorProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  final api = ref.watch(usersApiProvider);
  // TODO: replace with `api.getUserById(userId)` once endpoint exists.
  return api.me();
});

// ─── Interaction state ────────────────────────────────────────────────

/// Current-user interaction state (liked / saved) for a given content id.
final contentInteractionsProvider =
    FutureProvider.family<InteractionState, String>((ref, contentId) async {
  final api = ref.watch(interactionsApiProvider);
  return api.getInteractionState(contentId);
});
