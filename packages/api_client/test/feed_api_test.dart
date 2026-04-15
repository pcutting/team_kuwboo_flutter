import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

/// Stubs the flutter_secure_storage method channel so the auth interceptor's
/// token read doesn't fail in a pure-Dart test environment.
void _stubSecureStorageChannel() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'read':
        return null;
      case 'readAll':
        return <String, String>{};
      default:
        return null;
    }
  });
}

/// A minimal Dio adapter that records the request it saw and replies with
/// the provided JSON body. No real network is touched.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.responseBody);

  final Map<String, dynamic> responseBody;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    lastRequest = options;
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(responseBody)));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

KuwbooApiClient _clientWith(_RecordingAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(
    baseUrl: 'https://api.test',
    dio: dio,
  );
}

void main() {
  setUpAll(_stubSecureStorageChannel);

  group('FeedApi', () {
    test('getHome decodes a paginated page and sends query params', () async {
      final adapter = _RecordingAdapter({
        'data': {
          'items': [
            {
              'id': 'c1',
              'type': 'VIDEO',
              'creatorId': 'u1',
              'createdAt': '2026-04-15T10:00:00.000Z',
              'caption': 'first',
            },
          ],
          'nextCursor': '2026-04-15T09:59:00.000Z',
          'hasMore': true,
        },
      });
      final feed = FeedApi(_clientWith(adapter));

      final page = await feed.getHome(tab: 'video', limit: 20);

      expect(page.items, hasLength(1));
      expect(page.items.first.id, 'c1');
      expect(page.nextCursor, '2026-04-15T09:59:00.000Z');
      expect(page.hasMore, isTrue);

      expect(adapter.lastRequest!.path, '/feed');
      expect(adapter.lastRequest!.queryParameters['tab'], 'video');
      expect(adapter.lastRequest!.queryParameters['limit'], 20);
      expect(adapter.lastRequest!.queryParameters.containsKey('cursor'), isFalse);
    });

    test('getHome forwards cursor on subsequent pages (roundtrip)', () async {
      final page1Adapter = _RecordingAdapter({
        'data': {
          'items': [
            {
              'id': 'c1',
              'type': 'VIDEO',
              'creatorId': 'u1',
              'createdAt': '2026-04-15T10:00:00.000Z',
            },
          ],
          'nextCursor': 'cursor-page-2',
          'hasMore': true,
        },
      });
      final feedPage1 = FeedApi(_clientWith(page1Adapter));
      final first = await feedPage1.getHome();

      // Second call uses the nextCursor from the first response.
      final page2Adapter = _RecordingAdapter({
        'data': {
          'items': [
            {
              'id': 'c2',
              'type': 'VIDEO',
              'creatorId': 'u1',
              'createdAt': '2026-04-15T09:00:00.000Z',
            },
          ],
          'hasMore': false,
        },
      });
      final feedPage2 = FeedApi(_clientWith(page2Adapter));
      final second = await feedPage2.getHome(cursor: first.nextCursor);

      expect(page2Adapter.lastRequest!.queryParameters['cursor'],
          'cursor-page-2');
      expect(second.items.first.id, 'c2');
      expect(second.hasMore, isFalse);
      expect(second.nextCursor, isNull);
    });

    test('getFollowing forwards moduleScope when provided', () async {
      final adapter = _RecordingAdapter({
        'data': {'items': <dynamic>[], 'hasMore': false},
      });
      final feed = FeedApi(_clientWith(adapter));

      await feed.getFollowing(
        tab: 'social',
        cursor: 'abc',
        moduleScope: 'video_making',
      );

      expect(adapter.lastRequest!.path, '/feed/following');
      expect(adapter.lastRequest!.queryParameters['tab'], 'social');
      expect(adapter.lastRequest!.queryParameters['cursor'], 'abc');
      expect(adapter.lastRequest!.queryParameters['moduleScope'],
          'video_making');
    });

    test('getTrending wraps a raw Content[] list into FeedResponse', () async {
      final adapter = _RecordingAdapter({
        'data': [
          {
            'id': 't1',
            'type': 'VIDEO',
            'creatorId': 'u1',
            'createdAt': '2026-04-15T10:00:00.000Z',
          },
          {
            'id': 't2',
            'type': 'POST',
            'creatorId': 'u2',
            'createdAt': '2026-04-15T09:00:00.000Z',
          },
        ],
      });
      final feed = FeedApi(_clientWith(adapter));

      final page = await feed.getTrending(limit: 10);

      expect(adapter.lastRequest!.path, '/feed/trending');
      expect(adapter.lastRequest!.queryParameters['tab'], 'home');
      expect(adapter.lastRequest!.queryParameters['limit'], 10);
      expect(page.items.map((c) => c.id), ['t1', 't2']);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('getDiscover wraps a raw Content[] list into FeedResponse', () async {
      final adapter = _RecordingAdapter({
        'data': [
          {
            'id': 'd1',
            'type': 'VIDEO',
            'creatorId': 'u1',
            'createdAt': '2026-04-15T10:00:00.000Z',
          },
        ],
      });
      final feed = FeedApi(_clientWith(adapter));

      final page = await feed.getDiscover(tab: 'shop');

      expect(adapter.lastRequest!.path, '/feed/discover');
      expect(adapter.lastRequest!.queryParameters['tab'], 'shop');
      expect(page.items, hasLength(1));
      expect(page.items.first.id, 'd1');
    });
  });
}
