import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Stubs the `flutter_secure_storage` method channel so the auth
/// interceptor's `getAccessToken()` call returns null instead of hitting
/// a missing platform binding.
void _stubSecureStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

/// Minimal request capture used by the fake adapter.
class _Captured {
  _Captured(this.method, this.path, this.body);
  final String method;
  final String path;
  final dynamic body;
}

/// Fake Dio adapter that returns a queued JSON response and records the
/// outgoing request. Avoids pulling in a mocking dependency.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.response);

  final Map<String, dynamic> response;
  final int status = 200;
  final List<_Captured> calls = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    dynamic body;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      final raw = utf8.decode(bytes, allowMalformed: true);
      body = raw.isEmpty ? null : jsonDecode(raw);
    }
    calls.add(_Captured(options.method, options.path, body));

    final payload = utf8.encode(jsonEncode(response));
    return ResponseBody.fromBytes(
      payload,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

KuwbooApiClient _client(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
}

Map<String, dynamic> _credJson({
  String id = 'c1',
  String type = 'phone',
  bool isPrimary = true,
  String? revokedAt,
}) => {
      'id': id,
      'userId': 'u1',
      'type': type,
      'identifier': '+447000000000',
      'verifiedAt': '2026-04-01T00:00:00.000Z',
      'isPrimary': isPrimary,
      'revokedAt': revokedAt,
      'createdAt': '2026-04-01T00:00:00.000Z',
    };

void main() {
  setUpAll(_stubSecureStorage);

  group('CredentialsApi', () {
    test('listMine unwraps credentials array', () async {
      final adapter = _FakeAdapter({
        'data': {
          'credentials': [
            _credJson(),
            _credJson(id: 'c2', type: 'email', isPrimary: false),
          ],
        },
      });
      final api = CredentialsApi(_client(adapter));

      final creds = await api.listMine();

      expect(creds, hasLength(2));
      expect(creds[0].id, 'c1');
      expect(creds[0].type, CredentialType.phone);
      expect(creds[0].isPrimary, isTrue);
      expect(creds[1].type, CredentialType.email);
      expect(adapter.calls.single.method, 'GET');
      expect(adapter.calls.single.path, '/credentials');
    });

    test('attach posts AttachCredentialDto including otp', () async {
      final adapter = _FakeAdapter({
        'data': {'credential': _credJson(id: 'c3', type: 'email')},
      });
      final api = CredentialsApi(_client(adapter));

      final dto = AttachCredentialDto(
        type: CredentialType.email,
        identifier: 'foo@example.com',
        otp: '123456',
      );
      final created = await api.attach(dto);

      expect(created.id, 'c3');
      expect(adapter.calls.single.method, 'POST');
      expect(adapter.calls.single.path, '/credentials');
      expect(adapter.calls.single.body, {
        'type': 'email',
        'identifier': 'foo@example.com',
        'otp': '123456',
      });
    });

    test('attach omits otp when null (SSO-attach path)', () {
      final dto = AttachCredentialDto(
        type: CredentialType.google,
        identifier: 'google-sub-123',
      );
      expect(dto.toJson().containsKey('otp'), isFalse);
    });

    test('revoke issues DELETE /credentials/:id', () async {
      final adapter = _FakeAdapter({'data': {}});
      final api = CredentialsApi(_client(adapter));

      await api.revoke('c1');

      expect(adapter.calls.single.method, 'DELETE');
      expect(adapter.calls.single.path, '/credentials/c1');
    });

    test('adminListUserCredentials hits admin surface', () async {
      final adapter = _FakeAdapter({
        'data': {
          'credentials': [
            _credJson(revokedAt: '2026-04-10T00:00:00.000Z'),
          ],
        },
      });
      final api = CredentialsApi(_client(adapter));

      final creds = await api.adminListUserCredentials('u42');

      expect(creds, hasLength(1));
      expect(creds[0].revokedAt, isNotNull);
      expect(adapter.calls.single.path, '/admin/users/u42/credentials');
    });

    test('adminRevokeUserCredential posts reason', () async {
      final adapter = _FakeAdapter({
        'data': {
          'credential':
              _credJson(revokedAt: '2026-04-11T00:00:00.000Z'),
        },
      });
      final api = CredentialsApi(_client(adapter));

      final result = await api.adminRevokeUserCredential(
        'u42',
        'c1',
        reason: 'stolen_phone',
      );

      expect(result.revokedAt, isNotNull);
      expect(adapter.calls.single.method, 'POST');
      expect(adapter.calls.single.path, '/admin/credentials/c1/revoke');
      expect(adapter.calls.single.body, {'reason': 'stolen_phone'});
    });
  });
}
