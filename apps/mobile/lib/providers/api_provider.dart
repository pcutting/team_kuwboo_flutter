import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

import '../config/environment.dart';

/// Shared [KuwbooApiClient] bound to the configured API base URL. This
/// owns the Dio instance, the auth interceptor, and secure token storage
/// for every authenticated service (auth / users / credentials / interests).
///
/// Feed continues to use its own legacy [dioProvider] below until the
/// feed endpoints (content / products / yoyo/nearby) land in the shared
/// client — tracked as D-series follow-up.
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

// ─── Legacy Dio for feed/products/yoyo ──────────────────────────────────
//
// The shared client wraps every response in a `data` envelope and exposes
// `unwrap()` helpers. The mobile feed layer was written against a raw Dio
// with a global unwrap interceptor; rather than rewrite the feed notifiers
// in this PR (scope: D2b), we keep a second Dio here that shares tokens
// with the shared client via the same secure storage.
//
// TODO D2c: once `kuwboo_api_client` exposes content / products / yoyo
// endpoints, delete this provider and route feed through `apiClientProvider`.
Dio _feedDio(Ref ref) {
  final client = ref.watch(apiClientProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await client.getAccessToken();
        if (token != null && options.headers['Authorization'] == null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final body = response.data;
        if (body is Map && body.containsKey('data') && body.length <= 2) {
          response.data = body['data'];
        }
        handler.next(response);
      },
    ),
  );
  return dio;
}

final dioProvider = Provider<Dio>(_feedDio);
