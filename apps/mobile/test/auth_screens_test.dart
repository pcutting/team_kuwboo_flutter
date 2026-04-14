import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'package:kuwboo_mobile/features/auth/login_screen.dart';
import 'package:kuwboo_mobile/features/auth/otp_screen.dart';
import 'package:kuwboo_mobile/providers/api_provider.dart';
import 'package:kuwboo_mobile/providers/auth_provider.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────

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
  Future<void> sendPhoneOtp({required String phone}) async {
    sendOtpCalls++;
    lastPhone = phone;
    if (sendOtpError != null) throw sendOtpError!;
  }

  @override
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    verifyOtpCalls++;
    lastPhone = phone;
    lastCode = code;
    if (verifyOtpError != null) throw verifyOtpError!;
    return verifyResult!;
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeUsersApi implements UsersApi {
  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
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

ProviderContainer _makeContainer(_FakeAuthApi api) {
  return ProviderContainer(
    overrides: [
      authApiProvider.overrideWithValue(api),
      usersApiProvider.overrideWithValue(_FakeUsersApi()),
    ],
  );
}

AuthResponse _mkAuth({bool isNewUser = false}) {
  return AuthResponse(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: User(
      id: 'u1',
      name: 'Alice',
      phone: '+441234567890',
      onboardingProgress: isNewUser
          ? OnboardingProgress.profile
          : OnboardingProgress.complete,
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    isNewUser: isNewUser,
  );
}

/// Stub the flutter_secure_storage method channel so [KuwbooApiClient]'s
/// token reads/writes don't blow up in the Flutter test environment.
void _stubSecureStorageChannel() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = <String, String>{};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?) ?? const {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return store[key];
      case 'write':
        store[key!] = args['value'] as String;
        return null;
      case 'delete':
        store.remove(key);
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(key);
    }
    return null;
  });
}

// ─── Tests ──────────────────────────────────────────────────────────────

void main() {
  setUp(_stubSecureStorageChannel);
  group('LoginScreen', () {
    testWidgets('rejects empty phone', (tester) async {
      final api = _FakeAuthApi();
      final container = _makeContainer(api);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      expect(find.text('Enter your phone number'), findsOneWidget);
      expect(api.sendOtpCalls, 0);
    });

    testWidgets('calls requestOtp with E.164 number on success', (tester) async {
      final api = _FakeAuthApi();
      final container = _makeContainer(api);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      // A known-valid US number (Google HQ) — the default IsoCode in tests
      // is US because the test runner reports no locale country code.
      await tester.enterText(find.byType(TextField), '6502530000');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(api.sendOtpCalls, 1, reason: 'sendPhoneOtp should have been invoked');
      expect(api.lastPhone, startsWith('+'),
          reason: 'phone should be normalized to E.164');
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
      final container = _makeContainer(api);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const LoginScreen(), container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '6502530000');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('SMS provider down'), findsOneWidget);
    });
  });

  group('OtpScreen', () {
    testWidgets('verifies and updates auth state', (tester) async {
      final api = _FakeAuthApi(verifyResult: _mkAuth());
      final container = _makeContainer(api);
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
      final container = _makeContainer(api);
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
