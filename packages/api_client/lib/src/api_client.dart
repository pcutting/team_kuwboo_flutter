import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Storage keys for auth tokens.
const _kAccessTokenKey = 'kuwboo_access_token';
const _kRefreshTokenKey = 'kuwboo_refresh_token';

/// Base API client with Dio, auth interceptor, and token refresh.
class KuwbooApiClient {
  KuwbooApiClient({
    required String baseUrl,
    FlutterSecureStorage? secureStorage,
    Dio? dio,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _dio.interceptors.add(_authInterceptor());
  }

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  /// Single-flight token refresh guard.
  ///
  /// When two concurrent requests both receive 401, only the first one
  /// hits `/auth/refresh`; the second awaits this completer and picks up
  /// whatever tokens (or error) the first call produced. Without this,
  /// the two refreshes race on secure-storage writes and whichever
  /// finishes second overwrites the winner's tokens with its own — leaving
  /// the app holding a refresh token the backend has already rotated out.
  Completer<TokenPair>? _refreshing;

  /// Exposed for sub-API classes to make requests.
  Dio get dio => _dio;

  /// Exposed for sub-API classes to access token storage.
  FlutterSecureStorage get secureStorage => _secureStorage;

  /// Save tokens after login or refresh.
  Future<void> saveTokens(TokenPair tokens) async {
    await Future.wait([
      _secureStorage.write(key: _kAccessTokenKey, value: tokens.accessToken),
      _secureStorage.write(key: _kRefreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  /// Clear tokens on logout.
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _kAccessTokenKey),
      _secureStorage.delete(key: _kRefreshTokenKey),
    ]);
  }

  /// Read the current access token (if any).
  Future<String?> getAccessToken() =>
      _secureStorage.read(key: _kAccessTokenKey);

  /// Read the current refresh token (if any).
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _kRefreshTokenKey);

  /// Perform a single-flight token refresh. The first concurrent caller
  /// does the actual HTTP call; subsequent callers await the same future.
  /// All waiters receive either the new [TokenPair] or the same error.
  Future<TokenPair> _refreshTokens() {
    final existing = _refreshing;
    if (existing != null) return existing.future;

    final completer = Completer<TokenPair>();
    _refreshing = completer;

    () async {
      try {
        final expiredAccess = await getAccessToken();
        final refreshToken = await getRefreshToken();
        if (expiredAccess == null || refreshToken == null) {
          throw DioException(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            type: DioExceptionType.badResponse,
            error: 'missing tokens for refresh',
          );
        }

        // Separate Dio instance avoids interceptor recursion.
        // Contract §4.7: expired access token in Authorization header,
        // refresh token in body.
        final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {
              'Authorization': 'Bearer $expiredAccess',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        final data = response.data['data'] as Map<String, dynamic>;
        final newTokens = TokenPair(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        await saveTokens(newTokens);
        completer.complete(newTokens);
      } catch (error, stack) {
        // Clear tokens so every 401 waiter drops to logged-out state
        // consistently instead of some retrying and some not.
        await clearTokens();
        completer.completeError(error, stack);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }

  /// Auth interceptor: adds Bearer token and handles 401 with refresh.
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        // Don't retry the refresh call itself.
        if (error.requestOptions.path.endsWith('/auth/refresh')) {
          await clearTokens();
          return handler.next(error);
        }

        final refreshToken = await getRefreshToken();
        if (refreshToken == null) {
          return handler.next(error);
        }

        try {
          final newTokens = await _refreshTokens();
          // Retry the original request with the new token.
          final retryOptions = error.requestOptions;
          retryOptions.headers['Authorization'] =
              'Bearer ${newTokens.accessToken}';
          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed — tokens have already been cleared by
          // _refreshTokens(). Propagate the original 401.
          return handler.next(error);
        }
      },
    );
  }

  /// Extract the `data` field from the backend's wrapped response.
  T unwrap<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    final wrapped = response.data as Map<String, dynamic>;
    return fromJson(wrapped['data'] as Map<String, dynamic>);
  }

  /// Extract a list from the `data` field.
  List<T> unwrapList<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final wrapped = response.data as Map<String, dynamic>;
    final list = wrapped['data'] as List<dynamic>;
    return list
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
