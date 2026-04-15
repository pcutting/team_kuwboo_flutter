import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_fake_adapter.dart';
import '_test_setup.dart';

void main() {
  setUpAll(installSecureStorageStub);

  KuwbooApiClient buildClient(FakeAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
  }

  test('likeContent returns typed LikeResponse', () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': {'liked': true, 'likeCount': 42},
      },
    );
    final api = InteractionsApi(buildClient(adapter));

    final res = await api.likeContent('ct1');

    expect(res, isA<LikeResponse>());
    expect(res.liked, isTrue);
    expect(res.likeCount, 42);
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/content/ct1/like');
  });

  test('saveContent returns typed SaveResponse', () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': {'saved': false, 'saveCount': 7},
      },
    );
    final api = InteractionsApi(buildClient(adapter));

    final res = await api.saveContent('ct1');

    expect(res, isA<SaveResponse>());
    expect(res.saved, isFalse);
    expect(res.saveCount, 7);
    expect(adapter.requests.single.path, '/content/ct1/save');
  });

  test('logView and logShare fire POST without parsing body', () async {
    final adapter = FakeAdapter((_) => {'data': null});
    final api = InteractionsApi(buildClient(adapter));

    await api.logView('ct1');
    await api.logShare('ct1');

    expect(adapter.requests[0].path, '/content/ct1/view');
    expect(adapter.requests[0].method, 'POST');
    expect(adapter.requests[1].path, '/content/ct1/share');
    expect(adapter.requests[1].method, 'POST');
  });

  test('getInteractionState returns typed InteractionState', () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': {
          'liked': true,
          'saved': false,
          'likeCount': 10,
          'saveCount': 2,
          'viewCount': 100,
          'shareCount': 3,
          'commentCount': 5,
        },
      },
    );
    final api = InteractionsApi(buildClient(adapter));

    final state = await api.getInteractionState('ct1');

    expect(state, isA<InteractionState>());
    expect(state.liked, isTrue);
    expect(state.saved, isFalse);
    expect(state.likeCount, 10);
    expect(state.saveCount, 2);
    expect(state.viewCount, 100);
    expect(state.shareCount, 3);
    expect(state.commentCount, 5);
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/content/ct1/interactions');
  });
}
