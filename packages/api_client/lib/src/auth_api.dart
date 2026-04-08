import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Authentication endpoints.
class AuthApi {
  AuthApi(this._client);

  final KuwbooApiClient _client;

  /// Request an OTP for phone-based login.
  Future<void> sendOtp({required String phone}) async {
    await _client.dio.post('/auth/otp/send', data: {'phone': phone});
  }

  /// Verify an OTP and receive auth tokens.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _client.dio.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    final authResponse = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(TokenPair(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    ));
    return authResponse;
  }

  /// Sign in with Google ID token.
  Future<AuthResponse> googleLogin({required String idToken}) async {
    final response = await _client.dio.post(
      '/auth/google',
      data: {'idToken': idToken},
    );
    final authResponse = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(TokenPair(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    ));
    return authResponse;
  }

  /// Sign in with Apple authorization code.
  Future<AuthResponse> appleLogin({
    required String authorizationCode,
    String? identityToken,
  }) async {
    final response = await _client.dio.post(
      '/auth/apple',
      data: {
        'authorizationCode': authorizationCode,
        if (identityToken != null) 'identityToken': identityToken,
      },
    );
    final authResponse = _client.unwrap(response, AuthResponse.fromJson);
    await _client.saveTokens(TokenPair(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    ));
    return authResponse;
  }

  /// Manually refresh the access token.
  Future<TokenPair> refreshToken() async {
    final currentRefresh = await _client.getRefreshToken();
    if (currentRefresh == null) {
      throw StateError('No refresh token available');
    }
    final response = await _client.dio.post(
      '/auth/refresh',
      data: {'refreshToken': currentRefresh},
    );
    final tokens = _client.unwrap(response, TokenPair.fromJson);
    await _client.saveTokens(tokens);
    return tokens;
  }

  /// Sign out and clear stored tokens.
  Future<void> logout() async {
    try {
      await _client.dio.post('/auth/logout');
    } finally {
      await _client.clearTokens();
    }
  }
}
