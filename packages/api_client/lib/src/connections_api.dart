import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Social connection endpoints (10 routes).
///
/// NOTE: listFollowers / listFollowing use OFFSET pagination
/// (`limit` + `offset`), not cursor. This diverges from the comments
/// API's cursor model and matches the canonical backend contract.
class ConnectionsApi {
  ConnectionsApi(this._client);

  final KuwbooApiClient _client;

  /// `POST /connections/follow` — follow a user.
  Future<Connection> follow(FollowDto dto) async {
    final response = await _client.dio.post(
      '/connections/follow',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Connection.fromJson);
  }

  /// `DELETE /connections/follow/:userId` — unfollow a user.
  /// Optional moduleScope allows unfollowing only the per-module edge.
  Future<void> unfollow(String userId, {ModuleScope? moduleScope}) async {
    await _client.dio.delete(
      '/connections/follow/$userId',
      queryParameters: {
        if (moduleScope != null) 'moduleScope': moduleScope.value,
      },
    );
  }

  /// `POST /connections/friend-request` — send a friend request.
  Future<FriendRequest> sendFriendRequest(FollowDto dto) async {
    final response = await _client.dio.post(
      '/connections/friend-request',
      data: dto.toJson(),
    );
    return _client.unwrap(response, FriendRequest.fromJson);
  }

  /// `POST /connections/friend-request/:id/accept`.
  Future<FriendRequest> acceptFriendRequest(String id) async {
    final response =
        await _client.dio.post('/connections/friend-request/$id/accept');
    return _client.unwrap(response, FriendRequest.fromJson);
  }

  /// `POST /connections/friend-request/:id/reject`.
  Future<void> rejectFriendRequest(String id) async {
    await _client.dio.post('/connections/friend-request/$id/reject');
  }

  /// `GET /connections/followers` — OFFSET-paginated.
  Future<List<Connection>> listFollowers({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.dio.get(
      '/connections/followers',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _client.unwrapList(response, Connection.fromJson);
  }

  /// `GET /connections/following` — OFFSET-paginated.
  Future<List<Connection>> listFollowing({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.dio.get(
      '/connections/following',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _client.unwrapList(response, Connection.fromJson);
  }

  /// `POST /blocks` — block a user.
  Future<void> block(BlockDto dto) async {
    await _client.dio.post('/blocks', data: dto.toJson());
  }

  /// `DELETE /blocks/:userId` — unblock a user.
  Future<void> unblock(String userId) async {
    await _client.dio.delete('/blocks/$userId');
  }

  /// `GET /blocks` — list blocked users.
  Future<List<Map<String, dynamic>>> listBlocks() async {
    final response = await _client.dio.get('/blocks');
    final wrapped = response.data as Map<String, dynamic>;
    final list = wrapped['data'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
