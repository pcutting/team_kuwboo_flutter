import 'dart:convert';

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
      .setMockMethodCallHandler(channel, (call) async {
    // All reads return null (no tokens), writes/deletes succeed.
    if (call.method == 'read' || call.method == 'readAll') return null;
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsApi', () {
    late Dio dio;
    late _FakeAdapter adapter;
    late KuwbooApiClient client;
    late NotificationsApi api;

    setUp(() {
      _stubSecureStorage();
      dio = Dio();
      adapter = _FakeAdapter((_) => _json({'data': {}}));
      dio.httpClientAdapter = adapter;
      client = KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
      api = NotificationsApi(client);
    });

    test('constructs', () {
      expect(api, isNotNull);
    });

    test('list() hits /notifications and parses NotificationPage', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {
            'items': [
              {
                'id': 'n1',
                'type': 'LIKE',
                'title': 'New like',
                'body': 'Someone liked your post',
                'data': null,
                'readAt': null,
                'createdAt': '2026-01-01T00:00:00.000Z',
              },
            ],
            'nextCursor': '2026-01-01T00:00:00.000Z',
          },
        }),
      );
      dio.httpClientAdapter = adapter;

      final page = await api.list(cursor: 'abc', limit: 10);

      expect(adapter.lastRequest!.path, '/notifications');
      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.queryParameters['cursor'], 'abc');
      expect(adapter.lastRequest!.queryParameters['limit'], 10);
      expect(page.items, hasLength(1));
      expect(page.items.first.type, NotificationType.like);
      expect(page.nextCursor, '2026-01-01T00:00:00.000Z');
    });

    test('getUnreadCount() returns int from {count}', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {'count': 7},
        }),
      );
      dio.httpClientAdapter = adapter;

      final n = await api.getUnreadCount();
      expect(adapter.lastRequest!.path, '/notifications/unread-count');
      expect(n, 7);
    });

    test('markRead() PATCHes /notifications/:id/read', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {'message': 'Marked as read'},
        }),
      );
      dio.httpClientAdapter = adapter;

      final msg = await api.markRead('abc-123');
      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/notifications/abc-123/read');
      expect(msg, 'Marked as read');
    });

    test('markAllRead() PATCHes /notifications/read-all', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': {'message': '3 notifications marked as read'},
        }),
      );
      dio.httpClientAdapter = adapter;

      final msg = await api.markAllRead();
      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/notifications/read-all');
      expect(msg, contains('marked as read'));
    });

    test('getPreferences() returns list', () async {
      adapter = _FakeAdapter(
        (_) => _json({
          'data': [
            {
              'id': 'p1',
              'user': {'id': 'u1'},
              'moduleKey': 'video_making',
              'eventType': 'LIKE',
              'pushEnabled': true,
              'inAppEnabled': false,
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          ],
        }),
      );
      dio.httpClientAdapter = adapter;

      final prefs = await api.getPreferences();
      expect(prefs, hasLength(1));
      expect(prefs.first.moduleKey, 'video_making');
      expect(prefs.first.userId, 'u1');
      expect(prefs.first.pushEnabled, true);
      expect(prefs.first.inAppEnabled, false);
    });

    test('updatePreferences() sends preferences array', () async {
      adapter = _FakeAdapter(
        (_) => _json({'data': []}),
      );
      dio.httpClientAdapter = adapter;

      await api.updatePreferences(
        const UpdatePreferencesDto(
          preferences: [
            NotificationPreferenceItem(
              moduleKey: 'buy_sell',
              eventType: 'BID_PLACED',
              pushEnabled: false,
            ),
          ],
        ),
      );

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/notifications/preferences');
      final body = jsonDecode(adapter.lastBody!) as Map<String, dynamic>;
      expect(body['preferences'], isA<List<dynamic>>());
      final item = (body['preferences'] as List).first as Map<String, dynamic>;
      expect(item['moduleKey'], 'buy_sell');
      expect(item['eventType'], 'BID_PLACED');
      expect(item['pushEnabled'], false);
      expect(item.containsKey('inAppEnabled'), false);
    });
  });
}
