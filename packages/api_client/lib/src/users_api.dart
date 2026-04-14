import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Identity-subsystem user endpoints. See IDENTITY_CONTRACT §11.
class UsersApi {
  UsersApi(this._client);

  final KuwbooApiClient _client;

  Future<User> me() async {
    final response = await _client.dio.get('/users/me');
    return _client.unwrap(response, User.fromJson);
  }

  /// Patch a subset of the authenticated user's profile fields. Keys that
  /// are omitted are left untouched; pass explicit `null` to clear
  /// nullable columns where the backend supports it.
  Future<User> patchMe(Map<String, dynamic> partial) async {
    final response = await _client.dio.patch('/users/me', data: partial);
    return _client.unwrap(response, User.fromJson);
  }

  /// Check if a username handle is free. Returns `true` if the handle is
  /// available to claim.
  Future<bool> usernameAvailable(String handle) async {
    final response = await _client.dio.get(
      '/users/username-available',
      queryParameters: {'handle': handle},
    );
    return _client.unwrap(
      response,
      (json) => json['available'] as bool,
    );
  }

  /// Mark the tutorial complete for the given version.
  Future<User> markTutorialComplete({required int version}) async {
    final response = await _client.dio.post(
      '/users/me/tutorial-complete',
      data: {'version': version},
    );
    return _client.unwrap(response, User.fromJson);
  }
}
