import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  // In-memory fallback for environments where secure storage is broken
  // (notably the iOS Simulator, where flutter_secure_storage throws
  // PlatformException -34018 because the simulator process lacks a
  // Keychain entitlement). Without this fallback a successful verifyOtp
  // throws on saveTokens — the user sees "Invalid code: PlatformException"
  // even though the backend already minted valid tokens. With this
  // fallback, the session stays authenticated until app termination;
  // tokens are gone after a cold start, but the demo can proceed.
  String? _memAccessToken;
  String? _memRefreshToken;

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

  /// Save tokens after login or refresh. Always populates the in-memory
  /// cache; secure-storage failures are swallowed so a Keychain bug
  /// can't fail an otherwise-successful auth flow.
  Future<void> saveTokens(TokenPair tokens) async {
    _memAccessToken = tokens.accessToken;
    _memRefreshToken = tokens.refreshToken;
    if (kDebugMode) {
      final suffix = tokens.accessToken.substring(tokens.accessToken.length - 8);
      debugPrint('[api] saveTokens access=…$suffix');
    }
    try {
      await Future.wait([
        _secureStorage.write(key: _kAccessTokenKey, value: tokens.accessToken),
        _secureStorage.write(key: _kRefreshTokenKey, value: tokens.refreshToken),
      ]);
    } catch (_) {
      // In-memory copies above keep the session usable.
    }
  }

  /// Clear tokens on logout.
  Future<void> clearTokens() async {
    if (kDebugMode) {
      // Stack trace here is invaluable — 90% of "why did I log out?"
      // bugs come from unexpected clearTokens callers.
      debugPrint('[api] clearTokens called\n${StackTrace.current}');
    }
    _memAccessToken = null;
    _memRefreshToken = null;
    try {
      await Future.wait([
        _secureStorage.delete(key: _kAccessTokenKey),
        _secureStorage.delete(key: _kRefreshTokenKey),
      ]);
    } catch (_) {/* see saveTokens — storage may be unavailable */}
  }

  /// Read the current access token. Prefers in-memory (set by the most
  /// recent saveTokens) before hitting secure storage; if storage throws,
  /// falls back to in-memory (which may be null on a cold start).
  Future<String?> getAccessToken() async {
    if (_memAccessToken != null) return _memAccessToken;
    try {
      return await _secureStorage.read(key: _kAccessTokenKey);
    } catch (_) {
      return _memAccessToken;
    }
  }

  /// Read the current refresh token. Same fallback logic as
  /// [getAccessToken].
  Future<String?> getRefreshToken() async {
    if (_memRefreshToken != null) return _memRefreshToken;
    try {
      return await _secureStorage.read(key: _kRefreshTokenKey);
    } catch (_) {
      return _memRefreshToken;
    }
  }

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
        // consistently instead of some retrying and some not. A storage
        // failure here must not prevent completer.completeError from
        // firing — otherwise every awaiter hangs forever.
        try {
          await clearTokens();
        } catch (_) {/* secure storage unavailable */}
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
        // getAccessToken() is now self-protecting against secure-storage
        // failures (returns null instead of throwing). We still must
        // always call handler.next/reject so Dio doesn't deadlock.
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          // Last 8 chars of the token are enough to distinguish sessions
          // while staying out of logs. `-` means no Authorization attached.
          final suffix = token == null ? '-' : token.substring(token.length - 8);
          debugPrint(
            '[api] ${options.method} ${options.path} tok=$suffix',
          );
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }
        if (kDebugMode) {
          debugPrint(
            '[api] 401 on ${error.requestOptions.method} ${error.requestOptions.path} '
            'mem.access=${_memAccessToken != null} mem.refresh=${_memRefreshToken != null}',
          );
        }

        // Don't retry the refresh call itself.
        if (error.requestOptions.path.endsWith('/auth/refresh')) {
          if (kDebugMode) {
            debugPrint('[api] 401 on /auth/refresh — clearing tokens');
          }
          try {
            await clearTokens();
          } catch (_) {/* storage failure — nothing useful to do */}
          return handler.next(error);
        }

        String? refreshToken;
        try {
          refreshToken = await getRefreshToken();
        } catch (_) {
          // Same -34018 risk as above — fall through as if no token.
        }
        if (refreshToken == null) {
          if (kDebugMode) {
            debugPrint('[api] no refresh token — 401 propagated');
          }
          return handler.next(error);
        }

        try {
          final newTokens = await _refreshTokens();
          if (kDebugMode) {
            debugPrint('[api] refreshed successfully — retrying request');
          }
          // Retry the original request with the new token.
          final retryOptions = error.requestOptions;
          retryOptions.headers['Authorization'] =
              'Bearer ${newTokens.accessToken}';
          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh failed — tokens have already been cleared by
          // _refreshTokens(). Propagate the original 401.
          if (kDebugMode) {
            debugPrint('[api] refresh failed: $e — 401 propagated');
          }
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
