import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

import '../config/environment.dart';

/// Shared [KuwbooApiClient] bound to the configured API base URL.
final apiClientProvider = Provider<KuwbooApiClient>((ref) {
  return KuwbooApiClient(baseUrl: Environment.apiBaseUrl);
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(apiClientProvider)),
);

final credentialsApiProvider = Provider<CredentialsApi>(
  (ref) => CredentialsApi(ref.watch(apiClientProvider)),
);

final interestsApiProvider = Provider<InterestsApi>(
  (ref) => InterestsApi(ref.watch(apiClientProvider)),
);
