import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_fake_adapter.dart';
import '_test_setup.dart';

void main() {
  setUpAll(installSecureStorageStub);

  final createdAt = DateTime.utc(2026, 4, 15).toIso8601String();

  Map<String, dynamic> commentJson(String id, {String? parent}) => {
        'id': id,
        'contentId': 'c1',
        'authorId': 'u1',
        'text': 'hi',
        'likeCount': 0,
        'replyCount': 0,
        'parentCommentId': parent,
        'createdAt': createdAt,
      };

  KuwbooApiClient buildClient(FakeAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
  }

  test('createComment posts DTO payload and returns Comment', () async {
    final adapter = FakeAdapter(
      (_) => {'data': commentJson('cm1')},
    );
    final api = CommentsApi(buildClient(adapter));

    final result = await api.createComment(
      'c1',
      const CreateCommentDto(text: 'hi', parentCommentId: 'p1'),
    );

    expect(result.id, 'cm1');
    expect(adapter.requests, hasLength(1));
    final req = adapter.requests.single;
    expect(req.method, 'POST');
    expect(req.path, '/content/c1/comments');
    final body = req.data as Map<String, dynamic>;
    expect(body['text'], 'hi');
    expect(body['parentCommentId'], 'p1');
  });

  test('listComments forwards cursor + limit as query params', () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': [commentJson('cm1'), commentJson('cm2')],
      },
    );
    final api = CommentsApi(buildClient(adapter));

    final result = await api.listComments('c1', cursor: 'abc', limit: 10);

    expect(result, hasLength(2));
    final req = adapter.requests.single;
    expect(req.method, 'GET');
    expect(req.path, '/content/c1/comments');
    expect(req.queryParameters['cursor'], 'abc');
    expect(req.queryParameters['limit'], 10);
  });

  test('likeComment returns liked flag', () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': {'liked': true},
      },
    );
    final api = CommentsApi(buildClient(adapter));

    final liked = await api.likeComment('cm1');

    expect(liked, isTrue);
    expect(adapter.requests.single.path, '/comments/cm1/like');
    expect(adapter.requests.single.method, 'POST');
  });

  test('deleteComment issues DELETE', () async {
    final adapter = FakeAdapter((_) => {'data': null});
    final api = CommentsApi(buildClient(adapter));

    await api.deleteComment('cm1');

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/comments/cm1');
  });

  test('CreateCommentDto rejects text > 2000 chars', () {
    expect(
      () => CreateCommentDto(text: 'x' * 2001),
      throwsA(isA<AssertionError>()),
    );
  });
}
