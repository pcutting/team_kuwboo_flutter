import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_provider.dart';

/// Immutable web-side auth state. Tokens live in [KuwbooApiClient]'s secure
/// storage (localStorage on web); this copy is the synchronous read surface
/// for the router redirect and UI.
class AuthState {
  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isLoading = false,
    this.isNewUser = false,
  });

  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final bool isLoading;

  /// True immediately after verify-otp / register yields a brand-new
  /// account — UI keeps the user in the auth flow until onboarding
  /// completes.
  final bool isNewUser;

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    bool? isLoading,
    bool? isNewUser,
  }) => AuthState(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    isNewUser: isNewUser ?? this.isNewUser,
  );

  static const unauthenticated = AuthState();
}

/// Drives login / logout / OTP against the live backend. Tokens persist via
/// [KuwbooApiClient]'s secure storage so a full page refresh keeps the user
/// signed in.
///
/// SSO (Apple / Google) is not wired on web yet — the prototype only
/// exposes phone OTP + email + password paths. The SSO methods throw
/// [UnimplementedError] so any stray caller fails loudly instead of
/// silently "succeeding".
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  final Ref _ref;

  AuthApi get _authApi => _ref.read(authApiProvider);
  UsersApi get _usersApi => _ref.read(realUsersApiProvider);
  KuwbooApiClient get _client => _ref.read(realApiClientProvider);

  /// Hydrate auth state from secure storage on startup. If a valid token
  /// pair is present, fetch the current user to populate onboarding
  /// progress. A 401 here will clear tokens on the next authenticated
  /// call via the interceptor; we degrade silently so startup never hangs.
  Future<void> _init() async {
    try {
      final access = await _client.getAccessToken();
      final refresh = await _client.getRefreshToken();
      if (access == null || refresh == null) {
        state = AuthState.unauthenticated;
        return;
      }
      User? user;
      try {
        user = await _usersApi.me();
      } catch (_) {
        // Stay authenticated on transient errors; a real 401 will clear
        // tokens on the next call.
      }
      state = AuthState(
        accessToken: access,
        refreshToken: refresh,
        user: user,
        isNewUser: user?.onboardingProgress != OnboardingProgress.complete,
      );
    } catch (_) {
      state = AuthState.unauthenticated;
    }
  }

  Future<SendOtpResult> sendPhoneOtp(String phone) async {
    try {
      return await _authApi.sendPhoneOtp(phone: phone);
    } on DioException catch (e) {
      throw _translate(e, fallback: 'Could not send code');
    }
  }

  Future<SendOtpResult> sendEmailOtp(String email) async {
    try {
      return await _authApi.sendEmailOtp(email: email);
    } on DioException catch (e) {
      throw _translate(e, fallback: 'Could not send code');
    }
  }

  Future<AuthResponse> verifyOtp({
    required String identifier,
    required String code,
    required bool isPhone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = isPhone
          ? await _authApi.verifyPhoneOtp(phone: identifier, code: code)
          : await _authApi.verifyEmailOtp(email: identifier, code: code);
      await _applyAuthResponse(response);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Invalid code');
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<AuthResponse> emailRegister({
    required String email,
    required String password,
    String? name,
    required bool legalAccepted,
    required bool ageConfirmed,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authApi.registerWithEmail(
        email: email,
        password: password,
        name: name,
        legalAccepted: legalAccepted,
        ageConfirmed: ageConfirmed,
      );
      await _applyAuthResponse(response);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Could not create account');
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<AuthResponse> emailLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authApi.loginWithEmail(
        email: email,
        password: password,
      );
      await _applyAuthResponse(response);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Invalid email or password');
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> emailPasswordForgot(String email) async {
    try {
      await _authApi.forgotEmailPassword(email: email);
    } on DioException catch (e) {
      throw _translate(e, fallback: 'Could not send reset code');
    }
  }

  Future<AuthResponse> emailPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authApi.resetEmailPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      await _applyAuthResponse(response);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Invalid or expired code');
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Refresh the local user snapshot after an onboarding patch (birthday,
  /// profile, tutorial complete). Screens hit UsersApi directly; this
  /// syncs so the router redirect sees fresh onboardingProgress.
  Future<void> refreshUser() async {
    try {
      final user = await _usersApi.me();
      state = state.copyWith(
        user: user,
        isNewUser: user.onboardingProgress != OnboardingProgress.complete,
      );
    } catch (_) {
      // Non-fatal — next authenticated action will reconcile.
    }
  }

  void markOnboardingComplete() {
    if (state.isNewUser) state = state.copyWith(isNewUser: false);
  }

  Future<void> logout() async {
    try {
      if (state.accessToken != null) {
        await _authApi.logout();
      }
    } catch (_) {
      // Ignore; log out locally anyway.
    }
    await _client.clearTokens();
    state = AuthState.unauthenticated;
  }

  Future<void> _applyAuthResponse(AuthResponse r) async {
    state = AuthState(
      accessToken: r.accessToken,
      refreshToken: r.refreshToken,
      user: r.user,
      isNewUser:
          r.isNewUser ||
          r.user.onboardingProgress != OnboardingProgress.complete,
    );
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

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
