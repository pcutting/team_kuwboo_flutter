import 'package:dio/dio.dart';

import 'auth_models.dart';

/// Thin wrapper over the `/auth/*` routes on the Kuwboo backend.
///
/// Construct with a [Dio] already pointed at the API base URL. This class
/// does not attach `Authorization` headers — that is the responsibility of
/// the interceptor installed in `providers/api_provider.dart`.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// POST `/auth/phone/send-otp`
  Future<void> sendOtp(String phone) async {
    await _dio.post<dynamic>(
      '/auth/phone/send-otp',
      data: {'phone': phone},
    );
  }

  /// POST `/auth/phone/verify-otp`
  Future<AuthResponse> verifyOtp(String phone, String code) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/phone/verify-otp',
      data: {'phone': phone, 'code': code},
    );
    return AuthResponse.fromJson(res.data!);
  }

  /// POST `/auth/dev-login`
  ///
  /// Backend skips OTP, find-or-creates a user by phone, returns real JWTs.
  /// Only enabled when the server has `DEV_LOGIN_ENABLED=1` — otherwise 403.
  Future<AuthResponse> devLogin(String phone) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/dev-login',
      data: {'phone': phone},
    );
    return AuthResponse.fromJson(res.data!);
  }

  /// POST `/auth/refresh`
  ///
  /// Sends the expired access token in the `Authorization` header — the
  /// backend decodes (without verifying) the `sub` claim to find the user.
  Future<AuthTokens> refresh({
    required String expiredAccessToken,
    required String refreshToken,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {'Authorization': 'Bearer $expiredAccessToken'},
      ),
    );
    return AuthTokens.fromJson(res.data!);
  }

  /// POST `/auth/logout` (requires current access token via interceptor)
  Future<void> logout() async {
    await _dio.post<dynamic>('/auth/logout');
  }
}
