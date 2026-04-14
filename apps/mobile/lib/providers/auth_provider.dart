import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_models.dart';
import '../features/auth/data/token_storage.dart';
import 'api_provider.dart';

// ─── Auth State ──────────────────────────────────────────────────────────

/// Immutable authentication state.
class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final AuthUser? user;
  final bool isLoading;
  final bool isNewUser;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.user,
    this.isLoading = false,
    this.isNewUser = false,
  });

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    AuthUser? user,
    bool? isLoading,
    bool? isNewUser,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

// ─── Auth Notifier ───────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  final Ref _ref;

  TokenStorage get _storage => _ref.read(tokenStorageProvider);
  AuthApi get _api => _ref.read(authApiProvider);

  Future<void> _init() async {
    try {
      final tokens = await _storage.readTokens();
      final user = await _storage.readUser();
      if (tokens == null) {
        state = const AuthState();
        return;
      }
      state = AuthState(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        userId: user?.id,
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
      await _api.sendOtp(phone);
    } on DioException catch (e) {
      throw _translate(e, fallback: 'Could not send code');
    }
  }

  /// Verify OTP [code] for [phone], persist tokens, update state.
  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true);
    try {
      if (Environment.devAuthBypass && code == Environment.devBypassOtp) {
        const fakeTokens = AuthTokens(
          accessToken: 'dev-access',
          refreshToken: 'dev-refresh',
        );
        final fakeUser = AuthUser(
          id: 'dev-user',
          name: phone,
          phone: phone,
        );
        // Persist so dev sessions survive cold launches the same way real
        // sessions do — otherwise _init() finds nothing and bounces to /login.
        await _storage.writeTokens(fakeTokens);
        await _storage.writeUser(fakeUser);
        state = AuthState(
          accessToken: fakeTokens.accessToken,
          refreshToken: fakeTokens.refreshToken,
          userId: fakeUser.id,
          user: fakeUser,
        );
        return;
      }

      final response = await _api.verifyOtp(phone, code);
      await _storage.writeTokens(response.tokens);
      await _storage.writeUser(response.user);
      state = AuthState(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
        userId: response.user.id,
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

  /// Apply tokens refreshed by the Dio interceptor.
  Future<void> applyRefreshedTokens(AuthTokens tokens) async {
    await _storage.writeTokens(tokens);
    state = state.copyWith(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  /// Update local user snapshot (e.g. after onboarding profile PATCH).
  Future<void> updateUser(AuthUser user) async {
    await _storage.writeUser(user);
    state = state.copyWith(user: user, userId: user.id, isNewUser: false);
  }

  /// Mark onboarding complete without modifying the user record.
  void clearNewUserFlag() {
    if (state.isNewUser) state = state.copyWith(isNewUser: false);
  }

  /// Legacy direct-login helper retained for tests and any caller that
  /// already holds a token pair.
  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required String userId,
    bool isNewUser = false,
  }) async {
    await _storage.writeTokens(
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
    );
    state = AuthState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      isNewUser: isNewUser,
    );
  }

  /// Revoke server session (best-effort) and clear local storage.
  Future<void> logout() async {
    try {
      if (state.accessToken != null && !Environment.devAuthBypass) {
        await _api.logout();
      }
    } catch (_) {
      // Ignore — we are logging out anyway.
    }
    await _storage.clear();
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
