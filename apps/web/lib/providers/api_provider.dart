import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

/// Real API client for the web prototype, pointed at the live backend.
///
/// Override with `--dart-define=KUWBOO_API_BASE_URL=...` at build time to
/// aim at a different backend (e.g. local NestJS on `http://localhost:3000`).
/// Defaults to production so refreshing the page keeps the user authed
/// against the deployed backend.
String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('KUWBOO_API_BASE_URL');
  if (override.isNotEmpty) return override;
  return 'https://api.kuwboo.com';
}

final realApiClientProvider = Provider<KuwbooApiClient>((ref) {
  return KuwbooApiClient(baseUrl: _resolveApiBaseUrl());
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(realApiClientProvider)),
);

final realUsersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(realApiClientProvider)),
);

final interestsApiProvider = Provider<InterestsApi>(
  (ref) => InterestsApi(ref.watch(realApiClientProvider)),
);

// ─── Feed vertical ───────────────────────────────────────────────────────
//
// These providers exist for any direct consumer in the web layer. The
// shared `kuwboo_screens` package consumes its own per-module
// `apiClientProvider` (see `package_overrides.dart`) which is now also
// pointed at `realApiClientProvider` for the feed-vertical modules
// (video + social). Adding these here keeps the surface symmetrical with
// the rest of the de-mocked verticals (auth, users, interests, profile).

final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(realApiClientProvider)),
);

final contentApiProvider = Provider<ContentApi>(
  (ref) => ContentApi(ref.watch(realApiClientProvider)),
);

final commentsApiProvider = Provider<CommentsApi>(
  (ref) => CommentsApi(ref.watch(realApiClientProvider)),
);

final interactionsApiProvider = Provider<InteractionsApi>(
  (ref) => InteractionsApi(ref.watch(realApiClientProvider)),
);
