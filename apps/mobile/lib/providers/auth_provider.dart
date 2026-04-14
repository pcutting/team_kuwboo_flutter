import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../config/environment.dart';
import 'api_provider.dart';

// ─── Auth State ──────────────────────────────────────────────────────────

/// Immutable authentication state.
///
/// Mirrors the authoritative token pair + canonical [User] from
/// `kuwboo_models`. Tokens are authoritative in the shared client's secure
/// storage; the copy held here is for synchronous reads by UI + router.
class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final bool isLoading;
  final bool isNewUser;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isLoading = false,
    this.isNewUser = false,
  });

  bool get isAuthenticated => accessToken != null;

  String? get userId => user?.id;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    bool? isLoading,
    bool? isNewUser,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// ─── Auth Notifier ───────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  final Ref _ref;

  AuthApi get _authApi => _ref.read(authApiProvider);
  UsersApi get _usersApi => _ref.read(usersApiProvider);
  KuwbooApiClient get _client => _ref.read(apiClientProvider);

  Future<void> _init() async {
    try {
      final access = await _client.getAccessToken();
      final refresh = await _client.getRefreshToken();
      if (access == null || refresh == null) {
        state = const AuthState();
        return;
      }
      // Best-effort hydrate of the user snapshot from the backend.
      User? user;
      try {
        user = await _usersApi.me();
      } catch (_) {
        // 401 will trigger a logout on the next authenticated call; for
        // init we degrade gracefully and let the redirect bounce to /login
        // if tokens end up invalid.
        user = null;
      }
      state = AuthState(
        accessToken: access,
        refreshToken: refresh,
        user: user,
      );
    } catch (_) {
      state = const AuthState();
    }
  }

  /// Request an OTP for [phone] (E.164). When the dev bypass is enabled
  /// this is a no-op so the UI can flow without the SMS provider.
  Future<void> requestOtp(String phone) async {
    if (Environment.devAuthBypass) return;
    try {
      await _authApi.sendPhoneOtp(phone: phone);
    } on DioException catch (e) {
      throw _translate(e, fallback: 'Could not send code');
    }
  }

  /// Verify OTP [code] for [phone], persist tokens, update state.
  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true);
    try {
      final AuthResponse response;
      if (Environment.devAuthBypass && code == Environment.devBypassOtp) {
        // Backend's POST /auth/dev-login (gated by DEV_LOGIN_ENABLED=1)
        // returns real JWTs so feed/yoyo calls succeed end-to-end.
        response = await _authApi.devLogin(phone: phone);
      } else {
        response = await _authApi.verifyPhoneOtp(phone: phone, code: code);
      }
      state = AuthState(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
        isNewUser: response.isNewUser,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Invalid code');
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Update local user snapshot (e.g. after onboarding profile PATCH).
  void updateUser(User user) {
    state = state.copyWith(
      user: user,
      isNewUser: user.onboardingProgress != OnboardingProgress.complete,
    );
  }

  /// Mark onboarding complete without modifying the user record.
  void clearNewUserFlag() {
    if (state.isNewUser) state = state.copyWith(isNewUser: false);
  }

  /// Revoke server session (best-effort) and clear local storage.
  Future<void> logout() async {
    try {
      if (state.accessToken != null && !Environment.devAuthBypass) {
        await _authApi.logout();
      }
    } catch (_) {
      // Ignore — we are logging out anyway.
    }
    await _client.clearTokens();
    state = const AuthState();
  }

  /// Re-check stored credentials (e.g. after app resume).
  Future<void> checkAuth() async {
    await _init();
  }

  String _translate(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['message'] is List) {
      final list = (data['message'] as List).whereType<String>().toList();
      if (list.isNotEmpty) return list.first;
    }
    return fallback;
  }
}

// ─── Provider ────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
