import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_models.dart';
import 'auth_provider.dart';

/// Creates a raw [Dio] pointed at the API base URL. Used both by the main
/// [dioProvider] (via interceptors) and by the refresh flow (without
/// interceptors, to avoid infinite recursion on 401).
///
/// Includes a single global response interceptor that unwraps the
/// `{ data: T }` envelope the backend's TransformInterceptor wraps every
/// response in — so `fromJson` parsers see the flat payload.
Dio _rawDio() {
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

/// Un-intercepted Dio used exclusively for the refresh roundtrip.
final refreshDioProvider = Provider<Dio>((ref) => _rawDio());

/// Un-intercepted `AuthApi` for the refresh flow.
final refreshAuthApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(refreshDioProvider)),
);

/// Primary Dio for authenticated API calls. Attaches the current access
/// token and auto-refreshes on 401, redirecting to login on failure.
final dioProvider = Provider<Dio>((ref) {
  final dio = _rawDio();
  bool isRefreshing = false;
  Completer<void>? refreshCompleter;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authProvider).accessToken;
        if (token != null && options.headers['Authorization'] == null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final requestPath = error.requestOptions.path;
        final alreadyRetried =
            error.requestOptions.extra['__retried'] == true;

        // Never attempt refresh for auth endpoints themselves.
        final isAuthEndpoint = requestPath.startsWith('/auth/phone/') ||
            requestPath == '/auth/refresh' ||
            requestPath.startsWith('/auth/social/');

        if (status != 401 || alreadyRetried || isAuthEndpoint) {
          handler.next(error);
          return;
        }

        final notifier = ref.read(authProvider.notifier);
        final authState = ref.read(authProvider);
        final refreshToken = authState.refreshToken;
        final expiredAccess = authState.accessToken;

        if (refreshToken == null || expiredAccess == null) {
          await notifier.logout();
          handler.next(error);
          return;
        }

        // Coalesce concurrent 401s into a single refresh.
        if (isRefreshing && refreshCompleter != null) {
          try {
            await refreshCompleter!.future;
          } catch (_) {
            handler.next(error);
            return;
          }
        } else {
          isRefreshing = true;
          refreshCompleter = Completer<void>();
          try {
            final api = ref.read(refreshAuthApiProvider);
            final newTokens = await api.refresh(
              expiredAccessToken: expiredAccess,
              refreshToken: refreshToken,
            );
            await notifier.applyRefreshedTokens(newTokens);
            refreshCompleter!.complete();
          } catch (e) {
            refreshCompleter!.completeError(e);
            await notifier.logout();
            isRefreshing = false;
            refreshCompleter = null;
            handler.next(error);
            return;
          }
          isRefreshing = false;
          refreshCompleter = null;
        }

        // Retry the original request with the new token.
        final newToken = ref.read(authProvider).accessToken;
        final retryOptions = Options(
          method: error.requestOptions.method,
          headers: {
            ...error.requestOptions.headers,
            'Authorization': 'Bearer $newToken',
          },
          extra: {
            ...error.requestOptions.extra,
            '__retried': true,
          },
        );

        try {
          final response = await dio.request<dynamic>(
            error.requestOptions.path,
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
            options: retryOptions,
          );
          handler.resolve(response);
        } catch (e) {
          handler.next(error);
        }
      },
    ),
  );

  return dio;
});

/// Authenticated [AuthApi] used by the auth notifier for send-otp,
/// verify-otp, logout.
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(dioProvider)),
);

/// Re-export for convenience so consumers can do `AuthTokens` / `AuthUser`
/// imports alongside providers.
typedef SharedAuthTokens = AuthTokens;
typedef SharedAuthUser = AuthUser;
