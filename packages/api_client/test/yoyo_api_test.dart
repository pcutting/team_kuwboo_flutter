import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Stub the flutter_secure_storage method channel so the auth interceptor's
/// `getAccessToken()` call resolves to null in unit tests instead of blowing
/// up on a missing platform plugin.
void _stubSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    if (call.method == 'read' || call.method == 'readAll') return null;
    return null;
  });
}

/// Minimal in-process Dio adapter that records the last [RequestOptions]
/// and replies with a pre-baked JSON body. Avoids pulling in an extra
/// mocking dependency.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._responder);

  final Map<String, dynamic> Function(RequestOptions options) _responder;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final body = _responder(options);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Helper: build a client wired to a mock adapter with the given
/// response-generator closure.
({KuwbooApiClient client, _RecordingAdapter adapter}) _makeClient(
  Map<String, dynamic> Function(RequestOptions options) responder,
) {
  final dio = Dio();
  final adapter = _RecordingAdapter(responder);
  dio.httpClientAdapter = adapter;
  final client = KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
  return (client: client, adapter: adapter);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_stubSecureStorage);

  group('YoyoApi', () {
    test('updateLocation POSTs {latitude, longitude} to /yoyo/location', () async {
      final wired = _makeClient((_) => {'data': {'message': 'Location updated'}});
      final api = YoyoApi(wired.client);

      await api.updateLocation(
        const UpdateLocationDto(lat: 51.5, lng: -0.12),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/yoyo/location');
      expect(req.data, {'latitude': 51.5, 'longitude': -0.12});
    });

    test('getNearby GETs /yoyo/nearby with lat/lng/radius params', () async {
      final wired = _makeClient((_) => {
            'data': [
              {
                'id': 'u1',
                'name': 'Alice',
                'avatarUrl': null,
                'distanceMeters': 420,
                'onlineStatus': null,
              },
            ],
          });
      final api = YoyoApi(wired.client);

      final result =
          await api.getNearby(lat: 51.5, lng: -0.12, radius: 25);

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'GET');
      expect(req.path, '/yoyo/nearby');
      expect(req.queryParameters, {'lat': 51.5, 'lng': -0.12, 'radius': 25});
      expect(result, hasLength(1));
      expect(result.first.id, 'u1');
      expect(result.first.distanceMeters, 420);
    });

    test('getSettings GETs /yoyo/settings and unwraps data', () async {
      final wired = _makeClient((_) => {
            'data': {
              'isVisible': true,
              'radiusKm': 15,
              'ageMin': 18,
              'ageMax': 40,
              'genderFilter': 'female',
            },
          });
      final api = YoyoApi(wired.client);

      final settings = await api.getSettings();

      expect(wired.adapter.lastRequest!.method, 'GET');
      expect(wired.adapter.lastRequest!.path, '/yoyo/settings');
      expect(settings.radiusKm, 15);
      expect(settings.genderFilter, 'female');
    });

    test('updateSettings PATCHes /yoyo/settings with only provided fields', () async {
      final wired = _makeClient((_) => {
            'data': {
              'isVisible': false,
              'radiusKm': 50,
              'ageMin': null,
              'ageMax': null,
              'genderFilter': null,
            },
          });
      final api = YoyoApi(wired.client);

      final result = await api.updateSettings(
        const UpdateYoyoSettingsDto(isVisible: false, radiusKm: 50),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'PATCH');
      expect(req.path, '/yoyo/settings');
      expect(req.data, {'isVisible': false, 'radiusKm': 50});
      expect(result.isVisible, false);
      expect(result.radiusKm, 50);
    });

    test('createOverride POSTs to /yoyo/overrides with action value', () async {
      final wired = _makeClient((_) => {
            'data': {
              'id': 'ov1',
              'user': 'u1',
              'targetUser': 'u2',
              'action': 'BLOCK',
              'createdAt': '2026-04-15T10:00:00.000Z',
            },
          });
      final api = YoyoApi(wired.client);

      final override = await api.createOverride(
        const CreateOverrideDto(
          targetUserId: 'u2',
          action: OverrideAction.block,
        ),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/yoyo/overrides');
      expect(req.data, {'targetUserId': 'u2', 'action': 'BLOCK'});
      expect(override.action, OverrideAction.block);
      expect(override.targetUserId, 'u2');
    });

    test('sendWave POSTs to /yoyo/wave and returns Wave', () async {
      final wired = _makeClient((_) => {
            'data': {
              'id': 'w1',
              'fromUserId': 'u1',
              'toUserId': 'u2',
              'message': 'hi there',
              'status': 'PENDING',
              'createdAt': '2026-04-15T10:00:00.000Z',
            },
          });
      final api = YoyoApi(wired.client);

      final wave = await api.sendWave(
        const SendWaveDto(toUserId: 'u2', message: 'hi there'),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/yoyo/wave');
      expect(req.data, {'toUserId': 'u2', 'message': 'hi there'});
      expect(wave.id, 'w1');
      expect(wave.status, 'PENDING');
    });

    test('getWaves GETs /yoyo/waves and returns a list', () async {
      final wired = _makeClient((_) => {
            'data': [
              {
                'id': 'w1',
                'fromUserId': 'u1',
                'toUserId': 'u2',
                'message': null,
                'status': 'PENDING',
                'createdAt': '2026-04-15T10:00:00.000Z',
              },
              {
                'id': 'w2',
                'fromUserId': 'u3',
                'toUserId': 'u2',
                'message': 'hey',
                'status': 'PENDING',
                'createdAt': '2026-04-15T11:00:00.000Z',
              },
            ],
          });
      final api = YoyoApi(wired.client);

      final waves = await api.getWaves();

      expect(wired.adapter.lastRequest!.method, 'GET');
      expect(wired.adapter.lastRequest!.path, '/yoyo/waves');
      expect(waves, hasLength(2));
      expect(waves[1].message, 'hey');
    });

    test('respondToWave POSTs to /yoyo/waves/:id/respond with accept', () async {
      final wired = _makeClient((_) => {
            'data': {
              'id': 'w1',
              'fromUserId': 'u1',
              'toUserId': 'u2',
              'message': null,
              'status': 'ACCEPTED',
              'createdAt': '2026-04-15T10:00:00.000Z',
            },
          });
      final api = YoyoApi(wired.client);

      final result = await api.respondToWave(
        'w1',
        const RespondWaveDto(accept: true),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/yoyo/waves/w1/respond');
      expect(req.data, {'accept': true});
      expect(result.wave.id, 'w1');
      expect(result.wave.status, 'ACCEPTED');
    });
  });
}
