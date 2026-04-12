import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kuwboo_mobile/features/auth/data/auth_api.dart';
import 'package:kuwboo_mobile/features/auth/data/auth_models.dart';
import 'package:kuwboo_mobile/features/auth/data/token_storage.dart';
import 'package:kuwboo_mobile/features/auth/login_screen.dart';
import 'package:kuwboo_mobile/features/auth/otp_screen.dart';
import 'package:kuwboo_mobile/providers/api_provider.dart';
import 'package:kuwboo_mobile/providers/auth_provider.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────

class _FakeTokenStorage implements TokenStorage {
  AuthTokens? _tokens;
  AuthUser? _user;

  @override
  Future<void> clear() async {
    _tokens = null;
    _user = null;
  }

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<AuthUser?> readUser() async => _user;

  @override
  Future<void> writeTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> writeUser(AuthUser user) async => _user = user;
}

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({this.verifyResult, this.sendOtpError, this.verifyOtpError});

  AuthResponse? verifyResult;
  Object? sendOtpError;
  Object? verifyOtpError;
  int sendOtpCalls = 0;
  int verifyOtpCalls = 0;
  String? lastPhone;
  String? lastCode;

  @override
  Future<void> sendOtp(String phone) async {
    sendOtpCalls++;
    lastPhone = phone;
    if (sendOtpError != null) throw sendOtpError!;
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String code) async {
    verifyOtpCalls++;
    lastPhone = phone;
    lastCode = code;
    if (verifyOtpError != null) throw verifyOtpError!;
    return verifyResult!;
  }

  @override
  Future<AuthTokens> refresh({
    required String expiredAccessToken,
    required String refreshToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}
}

// ─── Helpers ────────────────────────────────────────────────────────────

Widget _wrap(Widget screen, ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => screen),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String? ?? ''),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

ProviderContainer _makeContainer(_FakeAuthApi api, _FakeTokenStorage storage) {
  return ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authApiProvider.overrideWithValue(api),
    ],
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('rejects empty phone', (tester) async {
      final api = _FakeAuthApi();
      final container = _makeContainer(api, _FakeTokenStorage());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      expect(find.text('Enter your phone number'), findsOneWidget);
      expect(api.sendOtpCalls, 0);
    });

    testWidgets('calls requestOtp and navigates on success', (tester) async {
      final api = _FakeAuthApi();
      final container = _makeContainer(api, _FakeTokenStorage());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+441234567890');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(api.sendOtpCalls, 1);
      expect(api.lastPhone, '+441234567890');
    });

    testWidgets('surfaces API error', (tester) async {
      final api = _FakeAuthApi(
        sendOtpError: DioException(
          requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
            statusCode: 500,
            data: {'message': 'SMS provider down'},
          ),
        ),
      );
      final container = _makeContainer(api, _FakeTokenStorage());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '+441234567890');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('SMS provider down'), findsOneWidget);
    });
  });

  group('OtpScreen', () {
    testWidgets('verifies and updates auth state', (tester) async {
      final api = _FakeAuthApi(
        verifyResult: const AuthResponse(
          tokens: AuthTokens(
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
          user: AuthUser(id: 'u1', name: 'Alice', phone: '+441234567890'),
          isNewUser: false,
        ),
      );
      final storage = _FakeTokenStorage();
      final container = _makeContainer(api, storage);
      addTearDown(container.dispose);

      // Seed the notifier.
      await container.read(authProvider.notifier).checkAuth();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OtpScreen(phone: '+441234567890'),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(api.verifyOtpCalls, 1);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.accessToken, 'access');
      expect(state.user?.name, 'Alice');
      expect(storage.readTokens(), completion(isNotNull));
    });

    testWidgets('shows error on invalid code', (tester) async {
      final api = _FakeAuthApi(
        verifyOtpError: DioException(
          requestOptions: RequestOptions(path: '/auth/phone/verify-otp'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/phone/verify-otp'),
            statusCode: 401,
            data: {'message': 'Invalid code'},
          ),
        ),
      );
      final container = _makeContainer(api, _FakeTokenStorage());
      addTearDown(container.dispose);
      await container.read(authProvider.notifier).checkAuth();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OtpScreen(phone: '+441234567890'),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '999999');
      await tester.tap(find.text('Verify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Invalid code'), findsOneWidget);
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });
  });
}
