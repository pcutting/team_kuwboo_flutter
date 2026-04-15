import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Captures the last request and returns a canned JSON body for every call.
class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this._body);

  final Map<String, dynamic> _body;
  final int statusCode = 200;

  RequestOptions? lastRequest;
  String? lastRequestBody;

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
      final chunks = <int>[];
      await for (final chunk in requestStream) {
        chunks.addAll(chunk);
      }
      lastRequestBody = utf8.decode(chunks);
    }
    final bytes = utf8.encode(jsonEncode(_body));
    return ResponseBody.fromBytes(
      bytes,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

KuwbooApiClient _clientWith(_MockAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(baseUrl: 'https://api.test', dio: dio);
}

Map<String, dynamic> _userJson({String id = 'u1'}) => {
      'id': id,
      'name': 'Test User',
      'createdAt': '2026-01-01T00:00:00.000Z',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('UsersApi', () {
    test('me() GETs /users/me and parses User', () async {
      final adapter = _MockAdapter({'data': _userJson()});
      final api = UsersApi(_clientWith(adapter));

      final user = await api.me();

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/users/me');
      expect(user.id, 'u1');
      expect(user.name, 'Test User');
    });

    test('patchMe() PATCHes /users/me with non-null fields only', () async {
      final adapter = _MockAdapter({'data': _userJson()});
      final api = UsersApi(_clientWith(adapter));

      await api.patchMe(const PatchMeDto(
        displayName: 'New Name',
        username: 'newhandle',
        onboardingProgress: OnboardingProgress.profile,
      ));

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/users/me');
      final sent = jsonDecode(adapter.lastRequestBody!) as Map<String, dynamic>;
      expect(sent['displayName'], 'New Name');
      expect(sent['username'], 'newhandle');
      expect(sent['onboardingProgress'], 'profile');
      expect(sent.containsKey('avatarUrl'), isFalse);
      expect(sent.containsKey('bio'), isFalse);
    });

    test('completeTutorial() POSTs /users/me/tutorial-complete with version',
        () async {
      final adapter = _MockAdapter({'data': _userJson()});
      final api = UsersApi(_clientWith(adapter));

      await api.completeTutorial(const TutorialCompleteDto(version: 3));

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/users/me/tutorial-complete');
      final sent = jsonDecode(adapter.lastRequestBody!) as Map<String, dynamic>;
      expect(sent['version'], 3);
    });

    test('isUsernameAvailable() GETs /users/username-available with handle',
        () async {
      final adapter = _MockAdapter({'data': {'available': true}});
      final api = UsersApi(_clientWith(adapter));

      final available = await api.isUsernameAvailable('phil');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/users/username-available');
      expect(adapter.lastRequest!.queryParameters, {'handle': 'phil'});
      expect(available, isTrue);
    });

    test('getUserById() GETs /users/:id and parses User', () async {
      final adapter = _MockAdapter({'data': _userJson(id: 'abc')});
      final api = UsersApi(_clientWith(adapter));

      final user = await api.getUserById('abc');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/users/abc');
      expect(user.id, 'abc');
    });

    test('updateUser() PATCHes /users/:id with non-null fields only',
        () async {
      final adapter = _MockAdapter({'data': _userJson(id: 'abc')});
      final api = UsersApi(_clientWith(adapter));

      await api.updateUser(
        'abc',
        const UpdateUserDto(name: 'Changed', latitude: 51.5),
      );

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/users/abc');
      final sent = jsonDecode(adapter.lastRequestBody!) as Map<String, dynamic>;
      expect(sent['name'], 'Changed');
      expect(sent['latitude'], 51.5);
      expect(sent.containsKey('longitude'), isFalse);
      expect(sent.containsKey('avatarUrl'), isFalse);
    });

    test('updatePreferences() PATCHes /users/:id/preferences', () async {
      final adapter = _MockAdapter({
        'data': {
          'notifications': {'likes': false},
          'privacy': {'showOnlineStatus': true},
        },
      });
      final api = UsersApi(_clientWith(adapter));

      final prefs = await api.updatePreferences(
        'abc',
        const UpdateUserPreferencesDto(
          notifications: NotificationPreferences(likes: false),
        ),
      );

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.path, '/users/abc/preferences');
      final sent = jsonDecode(adapter.lastRequestBody!) as Map<String, dynamic>;
      expect(sent['notifications'], isA<Map<String, dynamic>>());
      expect(sent.containsKey('privacy'), isFalse);
      expect(prefs['notifications'], isA<Map<String, dynamic>>());
    });
  });
}
