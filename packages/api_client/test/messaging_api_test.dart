import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Minimal in-memory Dio adapter so tests don't need `http_mock_adapter`.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;

  /// Every request that the API under test issued, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return await _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object body, {int status = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

KuwbooApiClient _clientWith(HttpClientAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub flutter_secure_storage's platform channel so the API client's
  // auth interceptor can read a (null) token without a real platform.
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('MessagingApi', () {
    test('createThread POSTs /threads with recipientId + moduleKey', () async {
      final adapter = _StubAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, '/threads');
        final body = options.data as Map<String, dynamic>;
        expect(body['recipientId'], 'user-2');
        expect(body['moduleKey'], 'BUY_SELL');
        expect(body['contextId'], 'ctx-1');
        return _jsonBody({
          'data': {
            'id': 'thread-1',
            'moduleKey': 'BUY_SELL',
            'contextId': 'ctx-1',
            'lastMessageText': null,
            'lastMessageSenderId': null,
            'lastMessageAt': null,
            'createdAt': '2026-04-15T10:00:00.000Z',
          },
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final thread = await api.createThread(
        const CreateThreadDto(
          recipientId: 'user-2',
          moduleKey: ThreadModuleKey.buySell,
          contextId: 'ctx-1',
        ),
      );

      expect(thread.id, 'thread-1');
      expect(thread.moduleKey, 'BUY_SELL');
      expect(thread.contextId, 'ctx-1');
    });

    test('createThread omits optional fields when null', () async {
      final adapter = _StubAdapter((options) {
        final body = options.data as Map<String, dynamic>;
        expect(body.containsKey('moduleKey'), isFalse);
        expect(body.containsKey('contextId'), isFalse);
        expect(body['recipientId'], 'user-2');
        return _jsonBody({
          'data': {
            'id': 'thread-2',
            'createdAt': '2026-04-15T10:00:00.000Z',
          },
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final thread =
          await api.createThread(const CreateThreadDto(recipientId: 'user-2'));
      expect(thread.id, 'thread-2');
      expect(thread.moduleKey, isNull);
    });

    test('listThreads sends cursor + limit and parses paginated response',
        () async {
      final adapter = _StubAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/threads');
        expect(options.queryParameters['limit'], 20);
        expect(options.queryParameters['cursor'], '2026-04-14T00:00:00.000Z');
        return _jsonBody({
          'data': {
            'items': [
              {
                'id': 'thread-1',
                'moduleKey': 'DATING',
                'createdAt': '2026-04-15T10:00:00.000Z',
              },
              {
                'id': 'thread-2',
                'createdAt': '2026-04-14T09:00:00.000Z',
              },
            ],
            'nextCursor': '2026-04-14T09:00:00.000Z',
          },
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final page = await api.listThreads(
        cursor: '2026-04-14T00:00:00.000Z',
      );

      expect(page.items, hasLength(2));
      expect(page.items.first.id, 'thread-1');
      expect(page.items.first.moduleKey, 'DATING');
      expect(page.nextCursor, '2026-04-14T09:00:00.000Z');
    });

    test('listThreads default limit is 20 and cursor is omitted', () async {
      final adapter = _StubAdapter((options) {
        expect(options.queryParameters['limit'], 20);
        expect(options.queryParameters.containsKey('cursor'), isFalse);
        return _jsonBody({
          'data': {'items': <Map<String, dynamic>>[]},
        });
      });
      final api = MessagingApi(_clientWith(adapter));
      final page = await api.listThreads();
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('listMessages GETs /threads/:id/messages with default limit 50',
        () async {
      final adapter = _StubAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/threads/thread-1/messages');
        expect(options.queryParameters['limit'], 50);
        return _jsonBody({
          'data': {
            'items': [
              {
                'id': 'msg-1',
                'threadId': 'thread-1',
                'senderId': 'user-1',
                'text': 'hello',
                'createdAt': '2026-04-15T10:00:00.000Z',
              },
            ],
            'nextCursor': null,
          },
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final page = await api.listMessages('thread-1');
      expect(page.items, hasLength(1));
      expect(page.items.first.text, 'hello');
      expect(page.items.first.senderId, 'user-1');
      expect(page.nextCursor, isNull);
    });

    test('sendMessage POSTs text + mediaId', () async {
      final adapter = _StubAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, '/threads/thread-1/messages');
        final body = options.data as Map<String, dynamic>;
        expect(body['text'], 'hi there');
        expect(body['mediaId'], 'media-1');
        return _jsonBody({
          'data': {
            'id': 'msg-2',
            'threadId': 'thread-1',
            'senderId': 'user-1',
            'text': 'hi there',
            'mediaId': 'media-1',
            'createdAt': '2026-04-15T10:01:00.000Z',
          },
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final msg = await api.sendMessage(
        'thread-1',
        SendMessageDto(text: 'hi there', mediaId: 'media-1'),
      );
      expect(msg.id, 'msg-2');
      expect(msg.mediaId, 'media-1');
    });

    test('SendMessageDto asserts text length <= 5000', () {
      expect(() => SendMessageDto(text: 'a' * 5001), throwsA(isA<AssertionError>()));
      // Boundary: exactly 5000 is allowed.
      expect(SendMessageDto(text: 'a' * 5000).text.length, 5000);
    });

    test('markThreadRead PATCHes and returns server message (read receipt)',
        () async {
      final adapter = _StubAdapter((options) {
        expect(options.method, 'PATCH');
        expect(options.path, '/threads/thread-1/read');
        return _jsonBody({
          'data': {'message': 'Thread marked as read'},
        });
      });
      final api = MessagingApi(_clientWith(adapter));

      final result = await api.markThreadRead('thread-1');
      expect(result, 'Thread marked as read');
    });

    test('ThreadModuleKey.fromValue round-trips backend enum strings', () {
      for (final v in ThreadModuleKey.values) {
        expect(ThreadModuleKey.fromValue(v.value), v);
      }
      expect(ThreadModuleKey.fromValue(null), isNull);
      expect(ThreadModuleKey.fromValue('NOT_A_REAL_KEY'), isNull);
    });
  });
}
