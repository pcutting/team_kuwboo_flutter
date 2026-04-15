import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  RequestOptions? lastRequest;
  String? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    lastRequest = options;
    if (requestStream != null) {
      final chunks = <int>[];
      await for (final chunk in requestStream) {
        chunks.addAll(chunk);
      }
      lastBody = utf8.decode(chunks);
    }
    return handler(options);
  }
}

ResponseBody _json(Map<String, dynamic> body, {int status = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void _stubSecureStorage() {
  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DevicesApi', () {
    late Dio dio;
    late _FakeAdapter adapter;
    late KuwbooApiClient client;
    late DevicesApi api;

    setUp(() {
      _stubSecureStorage();
      dio = Dio();
      adapter = _FakeAdapter((_) => _json({'data': {}}));
      dio.httpClientAdapter = adapter;
      client = KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
      api = DevicesApi(client);
    });

    test('constructs', () {
      expect(api, isNotNull);
    });

    test('register() POSTs /devices with fcmToken + platform', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {
            'id': 'd1',
            'user': {'id': 'u1'},
            'fcmToken': 'token-xyz',
            'platform': 'IOS',
            'appVersion': '1.0.0',
            'deviceModel': 'iPhone15,2',
            'osVersion': '18.1',
            'isActive': true,
            'lastActiveAt': '2026-01-01T00:00:00.000Z',
            'createdAt': '2026-01-01T00:00:00.000Z',
          },
        }),
      );
      dio.httpClientAdapter = adapter;

      final device = await api.register(
        const RegisterDeviceDto(
          fcmToken: 'token-xyz',
          platform: DevicePlatform.ios,
          appVersion: '1.0.0',
          deviceModel: 'iPhone15,2',
          osVersion: '18.1',
        ),
      );

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/devices');
      final body = jsonDecode(adapter.lastBody!) as Map<String, dynamic>;
      expect(body['fcmToken'], 'token-xyz');
      expect(body['platform'], 'IOS');
      expect(body['appVersion'], '1.0.0');

      expect(device.id, 'd1');
      expect(device.userId, 'u1');
      expect(device.platform, DevicePlatform.ios);
      expect(device.isActive, true);
    });

    test('deactivate() DELETEs /devices/:fcmToken', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {'message': 'Device deactivated'},
        }),
      );
      dio.httpClientAdapter = adapter;

      final msg = await api.deactivate('token-xyz');
      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.path, '/devices/token-xyz');
      expect(msg, 'Device deactivated');
    });
  });
}
