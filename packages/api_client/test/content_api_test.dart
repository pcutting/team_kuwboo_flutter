import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Minimal in-memory Dio adapter. Routes on `(method, path)` and returns
/// the queued JSON body. Also records the last request so tests can assert
/// on what was sent.
class _StubAdapter implements HttpClientAdapter {
  final Map<String, Map<String, dynamic>> _routes = {};

  RequestOptions? lastRequest;
  Map<String, dynamic>? lastBody;

  void on(String method, String path, Map<String, dynamic> response) {
    _routes['$method $path'] = response;
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (requestStream != null) {
      final bytes = <int>[];
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
      if (bytes.isNotEmpty) {
        lastBody = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      } else {
        lastBody = null;
      }
    } else {
      lastBody = null;
    }

    final key = '${options.method} ${options.path}';
    final body = _routes[key];
    if (body == null) {
      return ResponseBody.fromString(
        jsonEncode({'error': 'no route for $key'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

KuwbooApiClient _clientWith(_StubAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(baseUrl: 'https://api.test', dio: dio);
}

Map<String, dynamic> _videoContentJson({String id = 'vid-1'}) => {
      'id': id,
      'type': 'VIDEO',
      'creatorId': 'user-1',
      'visibility': 'PUBLIC',
      'tier': 'FREE',
      'status': 'ACTIVE',
      'likeCount': 0,
      'commentCount': 0,
      'viewCount': 0,
      'shareCount': 0,
      'saveCount': 0,
      'createdAt': '2026-04-15T00:00:00.000Z',
      'videoUrl': 'https://cdn.test/v.mp4',
      'thumbnailUrl': 'https://cdn.test/t.jpg',
      'durationSeconds': 30,
      'caption': 'hello',
    };

Map<String, dynamic> _postContentJson({String id = 'post-1'}) => {
      'id': id,
      'type': 'POST',
      'creatorId': 'user-1',
      'visibility': 'PUBLIC',
      'tier': 'FREE',
      'status': 'ACTIVE',
      'likeCount': 0,
      'commentCount': 0,
      'viewCount': 0,
      'shareCount': 0,
      'saveCount': 0,
      'createdAt': '2026-04-15T00:00:00.000Z',
      'text': 'hello world',
      'subType': 'STANDARD',
    };

void main() {
  // FlutterSecureStorage hits a MethodChannel on every request (for the
  // auth Bearer token); in unit tests we stub it to always return null so
  // no storage / keychain is touched.
  TestWidgetsFlutterBinding.ensureInitialized();
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
    if (call.method == 'readAll' || call.method == 'containsKey') {
      return <String, String>{};
    }
    return null;
  });

  group('ContentApi', () {
    test('createVideo posts DTO body and returns STI Content', () async {
      final adapter = _StubAdapter()
        ..on('POST', '/content/videos', {'data': _videoContentJson()});
      final api = ContentApi(_clientWith(adapter));

      final out = await api.createVideo(
        const CreateVideoDto(
          videoUrl: 'https://cdn.test/v.mp4',
          thumbnailUrl: 'https://cdn.test/t.jpg',
          durationSeconds: 30,
          caption: 'hello',
          visibility: Visibility.public_,
          tags: ['funny', 'cat'],
        ),
      );

      expect(out.id, 'vid-1');
      expect(out.type, ContentType.video);
      expect(out.videoUrl, 'https://cdn.test/v.mp4');
      expect(adapter.lastBody?['visibility'], 'PUBLIC');
      expect(adapter.lastBody?['tags'], ['funny', 'cat']);
      expect(adapter.lastBody?['durationSeconds'], 30);
      // No optional unset fields leak into the wire.
      expect(adapter.lastBody?.containsKey('musicId'), isFalse);
    });

    test('createPost serializes subType enum value', () async {
      final adapter = _StubAdapter()
        ..on('POST', '/content/posts', {'data': _postContentJson()});
      final api = ContentApi(_clientWith(adapter));

      final out = await api.createPost(
        const CreatePostDto(
          text: 'hello world',
          subType: PostSubType.blog,
          isPinned: true,
          visibility: Visibility.connections,
        ),
      );

      expect(out.type, ContentType.post);
      expect(out.text, 'hello world');
      expect(adapter.lastBody?['text'], 'hello world');
      expect(adapter.lastBody?['subType'], 'BLOG');
      expect(adapter.lastBody?['isPinned'], true);
      expect(adapter.lastBody?['visibility'], 'CONNECTIONS');
    });

    test('getInterestTags parses snake_case rows', () async {
      final adapter = _StubAdapter()
        ..on('GET', '/content/abc/interest-tags', {
          'data': {
            'interest_tags': [
              {
                'interest_id': 'int-1',
                'slug': 'cooking',
                'label': 'Cooking',
                'confidence': 0.85,
                'assigned_at': '2026-04-15T10:00:00.000Z',
              },
              {
                'interest_id': 'int-2',
                'slug': 'travel',
                'label': 'Travel',
              },
            ],
          },
        });
      final api = ContentApi(_clientWith(adapter));

      final tags = await api.getInterestTags('abc');
      expect(tags, hasLength(2));
      expect(tags[0].interestId, 'int-1');
      expect(tags[0].confidence, 0.85);
      expect(tags[0].assignedAt, isNotNull);
      expect(tags[1].confidence, isNull);
    });

    test('setInterestTags sends snake_case interest_ids body', () async {
      final adapter = _StubAdapter()
        ..on('POST', '/content/abc/interest-tags', {
          'data': {'interest_ids': ['int-1', 'int-2']},
        });
      final api = ContentApi(_clientWith(adapter));

      final ids = await api.setInterestTags(
        'abc',
        const SetInterestTagsDto(interestIds: ['int-1', 'int-2']),
      );

      expect(ids, ['int-1', 'int-2']);
      expect(adapter.lastBody?['interest_ids'], ['int-1', 'int-2']);
      // Must be snake_case on the wire.
      expect(adapter.lastBody?.containsKey('interestIds'), isFalse);
    });

    test('adminSetInterestTags posts to /admin/content/:id/interest-tags',
        () async {
      final adapter = _StubAdapter()
        ..on('POST', '/admin/content/abc/interest-tags', {
          'data': {'interest_ids': ['int-9']},
        });
      final api = ContentApi(_clientWith(adapter));

      final ids = await api.adminSetInterestTags(
        'abc',
        const SetInterestTagsDto(interestIds: ['int-9']),
      );

      expect(ids, ['int-9']);
      expect(adapter.lastRequest?.path, '/admin/content/abc/interest-tags');
    });

    test('hide / unhide / delete hit expected paths', () async {
      final adapter = _StubAdapter()
        ..on('PATCH', '/content/abc/hide', {'data': _videoContentJson()})
        ..on('PATCH', '/content/abc/unhide', {'data': _videoContentJson()})
        ..on('DELETE', '/content/abc', {'data': {}});
      final api = ContentApi(_clientWith(adapter));

      await api.hide('abc');
      expect(adapter.lastRequest?.method, 'PATCH');
      expect(adapter.lastRequest?.path, '/content/abc/hide');

      await api.unhide('abc');
      expect(adapter.lastRequest?.path, '/content/abc/unhide');

      await api.delete('abc');
      expect(adapter.lastRequest?.method, 'DELETE');
      expect(adapter.lastRequest?.path, '/content/abc');
    });

    test('getById fetches and parses STI Content', () async {
      final adapter = _StubAdapter()
        ..on('GET', '/content/abc', {'data': _videoContentJson(id: 'abc')});
      final api = ContentApi(_clientWith(adapter));

      final out = await api.getById('abc');
      expect(out.id, 'abc');
      expect(out.type, ContentType.video);
    });
  });
}
