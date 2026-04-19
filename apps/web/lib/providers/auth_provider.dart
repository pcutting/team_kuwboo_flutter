import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../mock/package_overrides.dart';

/// Minimal web-side auth state.
///
/// The mobile app has a fully-featured [AuthNotifier] in
/// `apps/mobile/lib/providers/auth_provider.dart` that drives the real
/// backend. Web cannot import that file because `apps/mobile/` is not
/// a pub dependency of `apps/web/`, so this file is a trimmed mirror
/// tailored to the prototype's needs: enough surface area to wire
/// `onLogout` through [KuwbooAuthFlow] and clear the mocked token
/// state when the Settings-screen logout button is tapped.
///
/// Non-logout callbacks (send OTP, SSO, onboarding) are either no-ops
/// or thin wrappers that throw `UnimplementedError` — the web prototype
/// does not currently exercise those paths at runtime.
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

/// Web-only auth notifier. Drives the mocked [KuwbooApiClient] via the
/// `mockApiClientProvider` so `onLogout` resolves against the mock
/// interceptor (owned by Agent C).
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  KuwbooApiClient get _client => _ref.read(mockApiClientProvider);
  AuthApi get _authApi => AuthApi(_client);

  /// Revoke the session on the (mocked) server and clear local token
  /// state. Mirrors the mobile notifier's [logout] contract.
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Mock interceptor should accept `/auth/logout`; swallow any
      // unexpected errors so the UI still transitions out cleanly.
    }
    try {
      await _client.clearTokens();
    } catch (_) {
      // Mock storage is in-memory — clearing is best-effort.
    }
    state = AuthState.unauthenticated;
  }
}

/// Riverpod handle matching the mobile app's shape, so shared screens
/// can read `ref.read(authProvider.notifier).logout` without caring
/// which host they're running under.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
