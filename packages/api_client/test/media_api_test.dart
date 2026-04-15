import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Minimal in-memory adapter that records each outbound request and
/// returns a scripted response. Keeps the test suite free of any HTTP
/// traffic and lets us assert on headers / body / URL directly.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._responder);

  final ResponseBody Function(RequestOptions options, List<int> body)
      _responder;
  final List<RequestOptions> requests = [];
  final List<List<int>> bodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final collected = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        collected.addAll(chunk);
      }
    }
    requests.add(options);
    bodies.add(collected);
    return _responder(options, collected);
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

void main() {
  // flutter_secure_storage goes through a platform channel; in unit tests
  // there is no native host. Stub the channel so the auth interceptor's
  // "read access token" call returns null instead of MissingPluginException.
  TestWidgetsFlutterBinding.ensureInitialized();
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return null;
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('MediaApi', () {
    late Dio authedDio;
    late Dio rawDio;
    late _RecordingAdapter authedAdapter;
    late _RecordingAdapter rawAdapter;
    late KuwbooApiClient client;
    late MediaApi api;

    setUp(() {
      authedDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      rawDio = Dio();
      client = KuwbooApiClient(baseUrl: 'https://api.test', dio: authedDio);
      // Register adapters after client wiring so interceptors stay intact.
      authedAdapter = _RecordingAdapter((options, _) {
        if (options.path.endsWith('/presigned-url')) {
          return _json({
            'data': {
              'uploadUrl': 'https://s3.test/bucket/key?sig=abc',
              'mediaId': 'media-123',
              's3Key': 'media/u1/xyz/cat.jpg',
            },
          });
        }
        if (options.path.contains('/confirm')) {
          return _json({
            'data': {
              'id': 'media-123',
              'uploaderId': 'u1',
              'type': 'IMAGE',
              's3Key': 'media/u1/xyz/cat.jpg',
              'url': 'https://cdn.test/media/u1/xyz/cat.jpg',
              'mimeType': 'image/jpeg',
              'sizeBytes': 42,
              'status': 'READY',
              'createdAt': '2026-04-15T10:00:00.000Z',
            },
          });
        }
        return _json({'error': 'unexpected'}, status: 500);
      });
      rawAdapter = _RecordingAdapter(
        (_, __) => ResponseBody.fromBytes(const [], 200, headers: {}),
      );
      authedDio.httpClientAdapter = authedAdapter;
      rawDio.httpClientAdapter = rawAdapter;
      api = MediaApi(client, rawDio: rawDio);
    });

    test('requestPresignedUrl posts DTO and unwraps response', () async {
      final response = await api.requestPresignedUrl(
        const PresignedUrlRequestDto(
          fileName: 'cat.jpg',
          contentType: 'image/jpeg',
          type: MediaType.image,
          sizeBytes: 42,
        ),
      );

      expect(authedAdapter.requests, hasLength(1));
      final req = authedAdapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/media/presigned-url');
      expect(req.data, {
        'fileName': 'cat.jpg',
        'contentType': 'image/jpeg',
        'type': 'IMAGE',
        'sizeBytes': 42,
      });
      expect(response.uploadUrl, 'https://s3.test/bucket/key?sig=abc');
      expect(response.mediaId, 'media-123');
      expect(response.s3Key, 'media/u1/xyz/cat.jpg');
    });

    test('requestPresignedUrl rejects oversize client-side', () async {
      expect(
        () => api.requestPresignedUrl(
          PresignedUrlRequestDto(
            fileName: 'big.jpg',
            contentType: 'image/jpeg',
            type: MediaType.image,
            sizeBytes: MediaLimits.imageMaxBytes + 1,
          ),
        ),
        throwsArgumentError,
      );
      expect(authedAdapter.requests, isEmpty);
    });

    test('requestPresignedUrl rejects disallowed content type', () async {
      expect(
        () => api.requestPresignedUrl(
          const PresignedUrlRequestDto(
            fileName: 'x.bmp',
            contentType: 'image/bmp',
            type: MediaType.image,
            sizeBytes: 1024,
          ),
        ),
        throwsArgumentError,
      );
      expect(authedAdapter.requests, isEmpty);
    });

    test('uploadFile issues raw PUT with signed content-type', () async {
      final bytes = Uint8List.fromList(List<int>.filled(16, 7));
      await api.uploadFile(
        'https://s3.test/bucket/key?sig=abc',
        bytes,
        'image/jpeg',
      );

      expect(authedAdapter.requests, isEmpty);
      expect(rawAdapter.requests, hasLength(1));
      final req = rawAdapter.requests.single;
      expect(req.method, 'PUT');
      expect(req.uri.toString(), 'https://s3.test/bucket/key?sig=abc');
      expect(req.headers[Headers.contentTypeHeader], 'image/jpeg');
      expect(req.headers[Headers.contentLengthHeader], 16);
      expect(rawAdapter.bodies.single, bytes);
    });

    test('confirm posts to /media/:id/confirm and returns Media', () async {
      final media = await api.confirm('media-123');

      expect(authedAdapter.requests, hasLength(1));
      final req = authedAdapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/media/media-123/confirm');
      expect(media.id, 'media-123');
      expect(media.status, MediaStatus.ready);
      expect(media.type, MediaType.image);
      expect(media.cdnUrl, 'https://cdn.test/media/u1/xyz/cat.jpg');
      expect(media.contentType, 'image/jpeg');
      expect(media.sizeBytes, 42);
      expect(media.ownerId, 'u1');
    });

    test('uploadAndConfirm composes all three steps', () async {
      final bytes = Uint8List.fromList(List<int>.filled(32, 1));
      final media = await api.uploadAndConfirm(
        fileName: 'cat.jpg',
        contentType: 'image/jpeg',
        type: MediaType.image,
        bytes: bytes,
      );

      // Two authed calls: presign + confirm. One raw S3 PUT.
      expect(authedAdapter.requests.map((r) => r.path).toList(), [
        '/media/presigned-url',
        '/media/media-123/confirm',
      ]);
      expect(rawAdapter.requests, hasLength(1));
      expect(
        rawAdapter.requests.single.headers[Headers.contentTypeHeader],
        'image/jpeg',
      );
      expect(media.status, MediaStatus.ready);
    });
  });

  group('MediaLimits', () {
    test('size caps match backend SIZE_LIMITS', () {
      expect(MediaLimits.imageMaxBytes, 10 * 1024 * 1024);
      expect(MediaLimits.audioMaxBytes, 20 * 1024 * 1024);
      expect(MediaLimits.videoMaxBytes, 100 * 1024 * 1024);
    });

    test('validate accepts allowed combos', () {
      expect(
        MediaLimits.validate(
          type: MediaType.video,
          contentType: 'video/mp4',
          sizeBytes: 1024,
        ),
        isNull,
      );
    });
  });
}
