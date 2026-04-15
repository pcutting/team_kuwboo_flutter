import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_fake_adapter.dart';
import '_test_setup.dart';

void main() {
  setUpAll(installSecureStorageStub);

  final createdAt = DateTime.utc(2026, 4, 15).toIso8601String();

  Map<String, dynamic> connectionJson(String id) => {
        'id': id,
        'fromUserId': 'u1',
        'toUserId': 'u2',
        'context': 'FOLLOW',
        'status': 'ACTIVE',
        'createdAt': createdAt,
      };

  Map<String, dynamic> friendRequestJson(String id) => {
        'id': id,
        'fromUserId': 'u1',
        'toUserId': 'u2',
        'status': 'PENDING',
        'createdAt': createdAt,
      };

  KuwbooApiClient buildClient(FakeAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
  }

  test('follow sends FollowDto payload including moduleScope', () async {
    final adapter = FakeAdapter(
      (_) => {'data': connectionJson('cn1')},
    );
    final api = ConnectionsApi(buildClient(adapter));

    final result = await api.follow(
      const FollowDto(userId: 'u2', moduleScope: ModuleScope.video),
    );

    expect(result.id, 'cn1');
    final req = adapter.requests.single;
    expect(req.method, 'POST');
    expect(req.path, '/connections/follow');
    final body = req.data as Map<String, dynamic>;
    expect(body['targetUserId'], 'u2');
    expect(body['moduleScope'], 'VIDEO');
  });

  test('unfollow forwards moduleScope as query param', () async {
    final adapter = FakeAdapter((_) => {'data': null});
    final api = ConnectionsApi(buildClient(adapter));

    await api.unfollow('u2', moduleScope: ModuleScope.shop);

    final req = adapter.requests.single;
    expect(req.method, 'DELETE');
    expect(req.path, '/connections/follow/u2');
    expect(req.queryParameters['moduleScope'], 'SHOP');
  });

  test('sendFriendRequest / accept / reject hit the right routes', () async {
    final adapter = FakeAdapter(
      (opts) => opts.path.endsWith('/reject')
          ? {'data': null}
          : {'data': friendRequestJson('fr1')},
    );
    final api = ConnectionsApi(buildClient(adapter));

    final sent = await api.sendFriendRequest(const FollowDto(userId: 'u2'));
    final accepted = await api.acceptFriendRequest('fr1');
    await api.rejectFriendRequest('fr2');

    expect(sent.id, 'fr1');
    expect(accepted.status, ConnectionStatus.pending);
    expect(adapter.requests[0].path, '/connections/friend-request');
    expect(adapter.requests[1].path, '/connections/friend-request/fr1/accept');
    expect(adapter.requests[2].path, '/connections/friend-request/fr2/reject');
  });

  test('listFollowers uses OFFSET pagination (limit + offset, NOT cursor)',
      () async {
    final adapter = FakeAdapter(
      (_) => {
        'data': [connectionJson('cn1'), connectionJson('cn2')],
      },
    );
    final api = ConnectionsApi(buildClient(adapter));

    await api.listFollowers(limit: 50, offset: 100);

    final req = adapter.requests.single;
    expect(req.method, 'GET');
    expect(req.path, '/connections/followers');
    expect(req.queryParameters['limit'], 50);
    expect(req.queryParameters['offset'], 100);
    expect(
      req.queryParameters.containsKey('cursor'),
      isFalse,
      reason: 'connections endpoints MUST NOT use cursor pagination',
    );
  });

  test('listFollowers defaults to limit=20 offset=0', () async {
    final adapter = FakeAdapter((_) => {'data': []});
    final api = ConnectionsApi(buildClient(adapter));

    await api.listFollowers();

    final qp = adapter.requests.single.queryParameters;
    expect(qp['limit'], 20);
    expect(qp['offset'], 0);
  });

  test('listFollowing uses OFFSET pagination', () async {
    final adapter = FakeAdapter((_) => {'data': []});
    final api = ConnectionsApi(buildClient(adapter));

    await api.listFollowing(limit: 5, offset: 10);

    final req = adapter.requests.single;
    expect(req.path, '/connections/following');
    expect(req.queryParameters['limit'], 5);
    expect(req.queryParameters['offset'], 10);
    expect(req.queryParameters.containsKey('cursor'), isFalse);
  });

  test('block / unblock / listBlocks', () async {
    final adapter = FakeAdapter(
      (opts) => opts.method == 'GET'
          ? {
              'data': [
                {'id': 'b1', 'userId': 'u2'},
              ],
            }
          : {'data': null},
    );
    final api = ConnectionsApi(buildClient(adapter));

    await api.block(const BlockDto(userId: 'u2'));
    await api.unblock('u2');
    final blocks = await api.listBlocks();

    expect(blocks, hasLength(1));
    expect(adapter.requests[0].method, 'POST');
    expect(adapter.requests[0].path, '/blocks');
    final body = adapter.requests[0].data as Map<String, dynamic>;
    expect(body['targetUserId'], 'u2');

    expect(adapter.requests[1].method, 'DELETE');
    expect(adapter.requests[1].path, '/blocks/u2');

    expect(adapter.requests[2].method, 'GET');
    expect(adapter.requests[2].path, '/blocks');
  });
}
