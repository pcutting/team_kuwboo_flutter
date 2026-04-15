import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

void _stubSecureStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

class _Captured {
  _Captured(this.method, this.path, this.body);
  final String method;
  final String path;
  final dynamic body;
}

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

Map<String, dynamic> _interestJson({
  String id = 'i1',
  String slug = 'football',
  String label = 'Football',
  int displayOrder = 0,
  bool isActive = true,
}) => {
      'id': id,
      'slug': slug,
      'label': label,
      'category': 'sport',
      'displayOrder': displayOrder,
      'isActive': isActive,
      'createdAt': '2026-04-01T00:00:00.000Z',
      'updatedAt': '2026-04-01T00:00:00.000Z',
    };

void main() {
  setUpAll(_stubSecureStorage);

  group('InterestsApi — user + public', () {
    test('listAll fetches public taxonomy', () async {
      final adapter = _FakeAdapter({
        'data': {
          'interests': [_interestJson(), _interestJson(id: 'i2', slug: 'music')],
        },
      });
      final api = InterestsApi(_client(adapter));

      final result = await api.listAll();

      expect(result, hasLength(2));
      expect(result[0].slug, 'football');
      expect(adapter.calls.single.method, 'GET');
      expect(adapter.calls.single.path, '/interests');
    });

    test('listMine hits /users/me/interests', () async {
      final adapter = _FakeAdapter({
        'data': {
          'interests': [_interestJson()],
        },
      });
      final api = InterestsApi(_client(adapter));

      await api.listMine();

      expect(adapter.calls.single.path, '/users/me/interests');
    });

    test('selectMany posts interest_ids from DTO', () async {
      final adapter = _FakeAdapter({
        'data': {
          'interests': [_interestJson()],
        },
      });
      final api = InterestsApi(_client(adapter));

      final dto = SelectInterestsDto(interestIds: ['i1', 'i2', 'i3']);
      final result = await api.selectMany(dto);

      expect(result, hasLength(1));
      expect(adapter.calls.single.method, 'POST');
      expect(adapter.calls.single.path, '/users/me/interests');
      expect(adapter.calls.single.body, {
        'interest_ids': ['i1', 'i2', 'i3'],
      });
    });

    test('deselectOne issues DELETE', () async {
      final adapter = _FakeAdapter({'data': {}});
      final api = InterestsApi(_client(adapter));

      await api.deselectOne('i1');

      expect(adapter.calls.single.method, 'DELETE');
      expect(adapter.calls.single.path, '/users/me/interests/i1');
    });
  });

  group('InterestsApi — admin', () {
    test('adminListAll hits /admin/interests', () async {
      final adapter = _FakeAdapter({
        'data': {
          'interests': [_interestJson(isActive: false)],
        },
      });
      final api = InterestsApi(_client(adapter));

      final result = await api.adminListAll();

      expect(result.single.isActive, isFalse);
      expect(adapter.calls.single.path, '/admin/interests');
    });

    test('adminCreate posts CreateInterestDto', () async {
      final adapter = _FakeAdapter({
        'data': {'interest': _interestJson(id: 'i9', slug: 'chess')},
      });
      final api = InterestsApi(_client(adapter));

      final dto = CreateInterestDto(
        slug: 'chess',
        label: 'Chess',
        category: 'hobby',
        displayOrder: 5,
      );
      final created = await api.adminCreate(dto);

      expect(created.id, 'i9');
      expect(adapter.calls.single.method, 'POST');
      expect(adapter.calls.single.path, '/admin/interests');
      expect(adapter.calls.single.body, {
        'slug': 'chess',
        'label': 'Chess',
        'category': 'hobby',
        'display_order': 5,
      });
    });

    test('adminUpdate only sends provided fields', () async {
      final adapter = _FakeAdapter({
        'data': {'interest': _interestJson(label: 'Football (soccer)')},
      });
      final api = InterestsApi(_client(adapter));

      final dto = UpdateInterestDto(label: 'Football (soccer)');
      final updated = await api.adminUpdate('i1', dto);

      expect(updated.label, 'Football (soccer)');
      expect(adapter.calls.single.method, 'PATCH');
      expect(adapter.calls.single.path, '/admin/interests/i1');
      expect(adapter.calls.single.body, {'label': 'Football (soccer)'});
    });

    test('adminDelete issues DELETE on admin surface', () async {
      final adapter = _FakeAdapter({'data': {}});
      final api = InterestsApi(_client(adapter));

      await api.adminDelete('i1');

      expect(adapter.calls.single.method, 'DELETE');
      expect(adapter.calls.single.path, '/admin/interests/i1');
    });

    test('adminReorder posts ordered_ids', () async {
      final adapter = _FakeAdapter({
        'data': {
          'interests': [_interestJson()],
        },
      });
      final api = InterestsApi(_client(adapter));

      final dto = ReorderInterestsDto(orderedIds: ['i2', 'i1', 'i3']);
      await api.adminReorder(dto);

      expect(adapter.calls.single.method, 'POST');
      expect(adapter.calls.single.path, '/admin/interests/reorder');
      expect(adapter.calls.single.body, {
        'ordered_ids': ['i2', 'i1', 'i3'],
      });
    });
  });
}
