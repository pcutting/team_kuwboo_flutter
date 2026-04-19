import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Host-app provides this override via `ProviderScope(overrides: [...])`.
final apiClientProvider = Provider<KuwbooApiClient>((ref) {
  throw UnimplementedError(
    'apiClientProvider must be overridden at the ProviderScope root.',
  );
});

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(apiClientProvider)),
);

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(apiClientProvider)),
);

final credentialsApiProvider = Provider<CredentialsApi>(
  (ref) => CredentialsApi(ref.watch(apiClientProvider)),
);

final interestsApiProvider = Provider<InterestsApi>(
  (ref) => InterestsApi(ref.watch(apiClientProvider)),
);

// ─── Current user ─────────────────────────────────────────────────────

final meProvider = FutureProvider.autoDispose<User>(
  (ref) => ref.watch(usersApiProvider).me(),
);

// ─── Notifications ────────────────────────────────────────────────────

final notificationsProvider = FutureProvider.autoDispose<NotificationPage>(
  (ref) => ref.watch(notificationsApiProvider).list(),
);

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationsApiProvider).getUnreadCount(),
);

final notificationPreferencesProvider =
    FutureProvider.autoDispose<List<NotificationPreference>>(
      (ref) => ref.watch(notificationsApiProvider).getPreferences(),
    );

// ─── Credentials + Interests (settings) ───────────────────────────────

final myCredentialsProvider = FutureProvider.autoDispose<List<Credential>>(
  (ref) => ref.watch(credentialsApiProvider).listMine(),
);

final myInterestsProvider = FutureProvider.autoDispose<List<Interest>>(
  (ref) => ref.watch(interestsApiProvider).listMine(),
);
