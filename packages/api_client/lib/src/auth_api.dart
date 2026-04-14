import 'package:dio/dio.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Result of an SSO (`/auth/google` | `/auth/apple`) call. The backend
/// returns a normal [AuthResponse] on 200, or a 409 Conflict carrying a
/// [PendingSsoChallenge] when the SSO email is already bound to another
/// account and the user must prove ownership via email OTP before linking.
sealed class SsoLoginResult {
  const SsoLoginResult();
}

class SsoLoginSuccess extends SsoLoginResult {
  const SsoLoginSuccess(this.auth);
  final AuthResponse auth;
}

class SsoLoginChallenge extends SsoLoginResult {
  const SsoLoginChallenge(this.challenge);
  final PendingSsoChallenge challenge;
}

/// Authentication endpoints — identity contract §11.
///
/// Unlike the other API classes this one deliberately avoids using the
/// shared auth interceptor for `refresh`: the refresh endpoint MUST include
/// the expired access token in the Authorization header AND the refresh
/// token in the body. The interceptor's own refresh flow uses the same
/// approach internally.
class AuthApi {
  AuthApi(this._client);

  final KuwbooApiClient _client;

  // ---------------------------------------------------------------------
  // Phone OTP
  // ---------------------------------------------------------------------

  Future<void> sendPhoneOtp({required String phone}) async {
    await _client.dio.post('/auth/phone/send-otp', data: {'phone': phone});
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _client.dio.post(
      '/auth/phone/verify-otp',
      data: {'phone': phone, 'code': code},
    );
    final auth = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(
      TokenPair(accessToken: auth.accessToken, refreshToken: auth.refreshToken),
    );
    return auth;
  }

  // ---------------------------------------------------------------------
  // Email OTP
  // ---------------------------------------------------------------------

  Future<void> sendEmailOtp({required String email}) async {
    await _client.dio.post('/auth/email/send-otp', data: {'email': email});
  }

  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final response = await _client.dio.post(
      '/auth/email/verify-otp',
      data: {'email': email, 'code': code},
    );
    final auth = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(
      TokenPair(accessToken: auth.accessToken, refreshToken: auth.refreshToken),
    );
    return auth;
  }

  // ---------------------------------------------------------------------
  // Google SSO
  // ---------------------------------------------------------------------

  /// Initiate a Google SSO session. On success, tokens are stored and the
  /// result is [SsoLoginSuccess]. If the Google account resolves to an
  /// email owned by a different user, the backend returns 409 Conflict and
  /// this method yields [SsoLoginChallenge] — call [googleConfirm] with the
  /// OTP the user receives via email to complete the link.
  Future<SsoLoginResult> google({required String idToken}) async {
    try {
      final response = await _client.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );
      final auth = _client.unwrap(response, AuthResponse.fromJson);
      await _client.saveTokens(
        TokenPair(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        ),
      );
      return SsoLoginSuccess(auth);
    } on DioException catch (e) {
      final challenge = _extractChallenge(e);
      if (challenge != null) return SsoLoginChallenge(challenge);
      rethrow;
    }
  }

  Future<AuthResponse> googleConfirm({
    required String idToken,
    required String emailOtp,
    required String challengeId,
  }) async {
    final response = await _client.dio.post(
      '/auth/google/confirm',
      data: {
        'idToken': idToken,
        'emailOtp': emailOtp,
        'challengeId': challengeId,
      },
    );
    final auth = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(
      TokenPair(accessToken: auth.accessToken, refreshToken: auth.refreshToken),
    );
    return auth;
  }

  // ---------------------------------------------------------------------
  // Apple SSO
  // ---------------------------------------------------------------------

  Future<SsoLoginResult> apple({
    required String identityToken,
    required String authorizationCode,
    String? fullName,
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/apple',
        data: {
          'identityToken': identityToken,
          'authorizationCode': authorizationCode,
          if (fullName != null) 'fullName': fullName,
        },
      );
      final auth = _client.unwrap(response, AuthResponse.fromJson);
      await _client.saveTokens(
        TokenPair(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        ),
      );
      return SsoLoginSuccess(auth);
    } on DioException catch (e) {
      final challenge = _extractChallenge(e);
      if (challenge != null) return SsoLoginChallenge(challenge);
      rethrow;
    }
  }

  Future<AuthResponse> appleConfirm({
    required String identityToken,
    required String emailOtp,
    required String challengeId,
  }) async {
    final response = await _client.dio.post(
      '/auth/apple/confirm',
      data: {
        'identityToken': identityToken,
        'emailOtp': emailOtp,
        'challengeId': challengeId,
      },
    );
    final auth = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(
      TokenPair(accessToken: auth.accessToken, refreshToken: auth.refreshToken),
    );
    return auth;
  }

  // ---------------------------------------------------------------------
  // Refresh + logout
  // ---------------------------------------------------------------------

  /// Rotate the token pair. Per IDENTITY_CONTRACT §4.7 the backend requires
  /// the *expired* access token in the `Authorization: Bearer` header and
  /// the refresh token in the JSON body. This call uses a clean Dio so the
  /// auth interceptor cannot recursively trigger its own refresh flow.
  Future<TokenPair> refresh() async {
    final expiredAccess = await _client.getAccessToken();
    final currentRefresh = await _client.getRefreshToken();
    if (expiredAccess == null || currentRefresh == null) {
      throw StateError('No tokens available to refresh');
    }
    final cleanDio = Dio(BaseOptions(baseUrl: _client.dio.options.baseUrl));
    final response = await cleanDio.post(
      '/auth/refresh',
      data: {'refreshToken': currentRefresh},
      options: Options(
        headers: {
          'Authorization': 'Bearer $expiredAccess',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    final auth = _client.unwrap(response, AuthResponse.fromJson);
    final tokens = TokenPair(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await _client.saveTokens(tokens);
    return tokens;
  }

  Future<void> logout() async {
    try {
      await _client.dio.post('/auth/logout');
    } finally {
      await _client.clearTokens();
    }
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// The `unwrapChallenge` backend helper emits 409 with body
  /// `{ code, challenge_id, email, require_verify_email }`. Our global
  /// response interceptor does NOT re-wrap error bodies, so the shape is
  /// read directly off `e.response?.data`.
  PendingSsoChallenge? _extractChallenge(DioException e) {
    if (e.response?.statusCode != 409) return null;
    final body = e.response?.data;
    if (body is! Map<String, dynamic>) return null;
    final inner = body['message'] is Map<String, dynamic>
        ? body['message'] as Map<String, dynamic>
        : body;
    if (inner['code'] != 'email_owned') return null;
    try {
      return PendingSsoChallenge.fromJson(inner);
    } catch (_) {
      return null;
    }
  }
}
