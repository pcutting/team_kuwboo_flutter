import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Consumers of the dating providers must override [datingApiProvider]
/// at the app level so the screens talk to the real, authenticated
/// [KuwbooApiClient]. In production `apps/mobile` supplies an override
/// built on top of `apiClientProvider`; tests override with a DatingApi
/// wrapping a mocked Dio.
final datingApiProvider = Provider<DatingApi>((ref) {
  throw UnimplementedError(
    'datingApiProvider must be overridden with a DatingApi instance '
    '(see apps/mobile providers/api_provider.dart).',
  );
});

/// Shared [InteractionsApi] used by the card stack for like/skip actions.
/// The dating "like" is the same backend toggle as content likes — the
/// module distinction is handled server-side by `moduleKey`.
final datingInteractionsApiProvider = Provider<InteractionsApi>((ref) {
  throw UnimplementedError(
    'datingInteractionsApiProvider must be overridden with an '
    'InteractionsApi instance.',
  );
});

/// `GET /dating/discover` — the primary swipe-stack data source.
/// Returns the paginated [DatingDiscoverPage]; the card stack typically
/// only cares about `page.items`, but keeping the page shape lets the
/// swipe screen paginate forward when the user burns through the first
/// batch of cards.
final datingCardsProvider = FutureProvider<DatingDiscoverPage>((ref) {
  return ref.watch(datingApiProvider).discover();
});

/// `GET /dating/matches` — active mutual matches.
final datingMatchesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(datingApiProvider).matches();
});

/// `GET /dating/likes` — likes received by the current user.
final datingLikesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(datingApiProvider).likes();
});

/// Expanded profile lookup for a candidate by user id. Uses the shared
/// users endpoint rather than the dating module because the backend
/// exposes profile data on `/users/:id` across every module.
///
/// `apps/mobile` should override [usersApiForDatingProvider] with the
/// real [UsersApi]; see [datingApiProvider] for the same pattern.
final usersApiForDatingProvider = Provider<UsersApi>((ref) {
  throw UnimplementedError(
    'usersApiForDatingProvider must be overridden with a UsersApi '
    'instance.',
  );
});

final userProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  // `UsersApi` does not yet expose a public-by-id lookup (only `me()`);
  // fall through to the shared client once the endpoint lands. For now
  // we return the current user when the id matches, otherwise throw so
  // the expanded-profile screen surfaces the gap explicitly rather than
  // silently rendering stale data.
  final users = ref.watch(usersApiForDatingProvider);
  final me = await users.me();
  if (me.id == userId) return me;
  throw UnimplementedError(
    'UsersApi.getById is not implemented yet (backend has no '
    'GET /users/:id endpoint). Dating expanded profile will show '
    'data embedded in the Content.creator payload instead.',
  );
});
