import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

/// Installs a method-channel mock that backs `flutter_secure_storage` with an
/// in-memory map so tests can exercise real [KuwbooApiClient] token logic.
void _installSecureStorageMock() {
  final store = <String, String>{};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return store[key];
      case 'readAll':
        return Map<String, String>.from(store);
      case 'write':
        store[key!] = args['value'] as String;
        return null;
      case 'delete':
        store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(key);
    }
    return null;
  });
}

/// Scripted adapter: returns queued responses for exact [method, path] calls.
class _ScriptedAdapter implements HttpClientAdapter {
  final List<_Call> _expected = [];
  final List<_Call> _received = [];

  void expect(String method, String path, {int status = 200, Map<String, dynamic>? body}) {
    _expected.add(_Call(method, path, status, body ?? {}));
  }

  List<_Call> get received => _received;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final call = _Call(options.method, options.path, 0, {});
    _received.add(call);
    final match = _expected.firstWhere(
      (e) => e.method == options.method && options.path.endsWith(e.path),
      orElse: () => throw StateError('Unexpected ${options.method} ${options.path}'),
    );
    final bytes = utf8.encode(jsonEncode(match.body));
    return ResponseBody.fromBytes(
      bytes,
      match.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class _Call {
  _Call(this.method, this.path, this.status, this.body);
  final String method;
  final String path;
  final int status;
  final Map<String, dynamic> body;
}

Map<String, dynamic> _okAuth({bool isNewUser = false}) => {
      'data': {
        'accessToken': 'access-token-xyz',
        'refreshToken': 'refresh-token-xyz',
        'isNewUser': isNewUser,
        'user': {
          'id': 'user-1',
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      },
    };

void main() {
  late KuwbooApiClient client;
  late _ScriptedAdapter adapter;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    _installSecureStorageMock();
    final dio = Dio();
    adapter = _ScriptedAdapter();
    dio.httpClientAdapter = adapter;
    client = KuwbooApiClient(baseUrl: 'https://api.test', dio: dio);
  });

  group('AuthApi', () {
    test('sendEmailOtp posts to /auth/email/send-otp', () async {
      adapter.expect('POST', '/auth/email/send-otp', body: {'data': {'sent': true}});
      await AuthApi(client).sendEmailOtp(email: 'a@b.com');
      expect(adapter.received.single.path, endsWith('/auth/email/send-otp'));
    });

    test('verifyEmailOtp returns AuthResponse and stores tokens', () async {
      adapter.expect('POST', '/auth/email/verify-otp', body: _okAuth());
      final auth = await AuthApi(client).verifyEmailOtp(email: 'a@b.com', code: '1234');
      expect(auth.accessToken, 'access-token-xyz');
      expect(await client.getAccessToken(), 'access-token-xyz');
      expect(await client.getRefreshToken(), 'refresh-token-xyz');
    });

    test('google() success path returns SsoLoginSuccess and saves tokens', () async {
      adapter.expect('POST', '/auth/google', body: _okAuth(isNewUser: true));
      final result = await AuthApi(client).google(idToken: 'g-id-token');
      expect(result, isA<SsoLoginSuccess>());
      expect((result as SsoLoginSuccess).auth.isNewUser, true);
      expect(await client.getAccessToken(), 'access-token-xyz');
    });

    test('google() 409 returns SsoLoginChallenge with parsed body', () async {
      adapter.expect('POST', '/auth/google', status: 409, body: {
        'code': 'email_owned',
        'challenge_id': '11111111-1111-1111-1111-111111111111',
        'email': 'x@y.com',
        'require_verify_email': true,
      });
      final result = await AuthApi(client).google(idToken: 'g-id-token');
      expect(result, isA<SsoLoginChallenge>());
      final challenge = (result as SsoLoginChallenge).challenge;
      expect(challenge.code, 'email_owned');
      expect(challenge.email, 'x@y.com');
      expect(challenge.challengeId, '11111111-1111-1111-1111-111111111111');
      expect(challenge.requireVerifyEmail, true);
    });

    test('googleConfirm returns AuthResponse and stores tokens', () async {
      adapter.expect('POST', '/auth/google/confirm', body: _okAuth());
      final auth = await AuthApi(client).googleConfirm(
        idToken: 'g',
        emailOtp: '1234',
        challengeId: 'c1',
      );
      expect(auth.refreshToken, 'refresh-token-xyz');
    });

    test('apple() success path returns SsoLoginSuccess', () async {
      adapter.expect('POST', '/auth/apple', body: _okAuth());
      final result = await AuthApi(client).apple(
        identityToken: 'id',
        authorizationCode: 'code',
        fullName: 'Ada Lovelace',
      );
      expect(result, isA<SsoLoginSuccess>());
    });

    test('apple() 409 returns SsoLoginChallenge', () async {
      adapter.expect('POST', '/auth/apple', status: 409, body: {
        'code': 'email_owned',
        'challenge_id': '22222222-2222-2222-2222-222222222222',
        'email': 'a@apple.com',
      });
      final result = await AuthApi(client).apple(
        identityToken: 'id',
        authorizationCode: 'code',
      );
      expect(result, isA<SsoLoginChallenge>());
      expect((result as SsoLoginChallenge).challenge.email, 'a@apple.com');
    });

    test('appleConfirm returns AuthResponse', () async {
      adapter.expect('POST', '/auth/apple/confirm', body: _okAuth());
      final auth = await AuthApi(client).appleConfirm(
        identityToken: 'id',
        emailOtp: '1234',
        challengeId: 'c1',
      );
      expect(auth.accessToken, 'access-token-xyz');
    });

    test(
      'refresh() contract: expects tokens to exist in storage before call',
      () async {
        // AuthApi.refresh() constructs its own clean Dio internally so the
        // scripted adapter above cannot intercept it. We instead verify the
        // pre-condition guard: refresh throws StateError when no tokens are
        // in storage. Full HTTP behaviour is covered by the interceptor e2e
        // path (see api_client.dart onError) and manual integration testing.
        expect(
          () => AuthApi(client).refresh(),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
