import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../config/environment.dart';
import 'api_provider.dart';

/// Immutable mobile-side auth state. The authoritative token pair lives in
/// [KuwbooApiClient]'s secure storage; this copy is for synchronous reads
/// by UI + router redirect.
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

  /// True immediately after verify-otp / SSO returns a brand-new account —
  /// UI keeps the user in the auth flow until onboarding is complete.
  final bool isNewUser;

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    bool? isLoading,
    bool? isNewUser,
  }) =>
      AuthState(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isNewUser: isNewUser ?? this.isNewUser,
      );

  static const unauthenticated = AuthState();
}

/// Drives login/logout/SSO against the live backend. Uses the shared
/// [KuwbooApiClient]'s secure storage for tokens so the Dio auth
/// interceptor can read them on every authenticated call.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  final Ref _ref;

  /// Cached SSO provider token from the most recent apple/google call that
  /// yielded a challenge. Used by [confirmSsoChallenge] because the
  /// backend's `/auth/{provider}/confirm` re-verifies the original token
  /// alongside the email OTP. Cleared on success or logout.
  String? _pendingAppleIdentityToken;
  String? _pendingGoogleIdToken;

  AuthApi get _authApi => _ref.read(authApiProvider);
  UsersApi get _usersApi => _ref.read(usersApiProvider);
  KuwbooApiClient get _client => _ref.read(apiClientProvider);

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
        // 401 on next authenticated call will clear tokens; degrade here.
      }
      state = AuthState(
        accessToken: access,
        refreshToken: refresh,
        user: user,
        isNewUser:
            user?.onboardingProgress != OnboardingProgress.complete,
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

  /// Verify phone or email OTP. On success persists tokens (via
  /// KuwbooApiClient secure storage) and updates [state].
  Future<AuthResponse> verifyOtp({
    required String identifier,
    required String code,
    required bool isPhone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final AuthResponse response;
      if (Environment.devAuthBypass && code == Environment.devBypassOtp) {
        response = await _authApi.devLogin(phone: identifier);
      } else if (isPhone) {
        response = await _authApi.verifyPhoneOtp(phone: identifier, code: code);
      } else {
        response = await _authApi.verifyEmailOtp(email: identifier, code: code);
      }
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

  Future<SsoLoginResult> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authApi.apple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        fullName: fullName,
      );
      if (result is SsoLoginSuccess) {
        _pendingAppleIdentityToken = null;
        await _applyAuthResponse(result.auth);
      } else {
        _pendingAppleIdentityToken = identityToken;
        state = state.copyWith(isLoading: false);
      }
      return result;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Apple sign-in failed');
    }
  }

  Future<SsoLoginResult> signInWithGoogle({required String idToken}) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authApi.google(idToken: idToken);
      if (result is SsoLoginSuccess) {
        _pendingGoogleIdToken = null;
        await _applyAuthResponse(result.auth);
      } else {
        _pendingGoogleIdToken = idToken;
        state = state.copyWith(isLoading: false);
      }
      return result;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Google sign-in failed');
    }
  }

  /// Confirm an SSO email-ownership challenge with the OTP the user
  /// received on their pre-existing account's email channel. Uses the
  /// cached provider token from the initial [signInWithApple] /
  /// [signInWithGoogle] call.
  Future<AuthResponse> confirmSsoChallenge(
    PendingSsoChallenge challenge,
    String emailOtp,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final AuthResponse response;
      if (_pendingAppleIdentityToken != null) {
        response = await _authApi.appleConfirm(
          identityToken: _pendingAppleIdentityToken!,
          emailOtp: emailOtp,
          challengeId: challenge.challengeId,
        );
        _pendingAppleIdentityToken = null;
      } else if (_pendingGoogleIdToken != null) {
        response = await _authApi.googleConfirm(
          idToken: _pendingGoogleIdToken!,
          emailOtp: emailOtp,
          challengeId: challenge.challengeId,
        );
        _pendingGoogleIdToken = null;
      } else {
        throw StateError(
          'No pending SSO token — retry sign-in before confirming.',
        );
      }
      await _applyAuthResponse(response);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      throw _translate(e, fallback: 'Could not confirm sign-in');
    }
  }

  /// Refresh the local user snapshot after an onboarding patch (birthday,
  /// profile, tutorial complete) — the screens themselves hit UsersApi
  /// directly; this just syncs state so the router redirect sees the new
  /// onboardingProgress.
  Future<void> refreshUser() async {
    try {
      final user = await _usersApi.me();
      state = state.copyWith(
        user: user,
        isNewUser:
            user.onboardingProgress != OnboardingProgress.complete,
      );
    } catch (_) {
      // Non-fatal. State will eventually reconcile on next authenticated
      // action.
    }
  }

  void markOnboardingComplete() {
    if (state.isNewUser) state = state.copyWith(isNewUser: false);
  }

  Future<void> logout() async {
    try {
      if (state.accessToken != null && !Environment.devAuthBypass) {
        await _authApi.logout();
      }
    } catch (_) {
      // Ignore; log out locally anyway.
    }
    _pendingAppleIdentityToken = null;
    _pendingGoogleIdToken = null;
    await _client.clearTokens();
    state = AuthState.unauthenticated;
  }

  Future<void> _applyAuthResponse(AuthResponse r) async {
    state = AuthState(
      accessToken: r.accessToken,
      refreshToken: r.refreshToken,
      user: r.user,
      isNewUser: r.isNewUser ||
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
