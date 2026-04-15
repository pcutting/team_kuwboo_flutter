import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Identity-subsystem user endpoints. See IDENTITY_CONTRACT §11 and the
/// canonical route list in `apps/api/src/modules/users/users.controller.ts`.
class UsersApi {
  UsersApi(this._client);

  final KuwbooApiClient _client;

  /// GET /users/me — fetch the authenticated user's profile.
  Future<User> me() async {
    final response = await _client.dio.get('/users/me');
    return _client.unwrap(response, User.fromJson);
  }

  /// PATCH /users/me — partial update of the authenticated user's profile.
  /// Pass only the fields you wish to mutate. Keys omitted from the DTO's
  /// JSON payload are ignored server-side.
  Future<User> patchMe(PatchMeDto dto) async {
    final response = await _client.dio.patch(
      '/users/me',
      data: _stripNulls(dto.toJson()),
    );
    return _client.unwrap(response, User.fromJson);
  }

  /// POST /users/me/tutorial-complete — mark the tutorial complete for the
  /// given version. The server returns the updated user profile.
  Future<User> completeTutorial(TutorialCompleteDto dto) async {
    final response = await _client.dio.post(
      '/users/me/tutorial-complete',
      data: dto.toJson(),
    );
    return _client.unwrap(response, User.fromJson);
  }

  /// GET /users/username-available?handle=… — returns `true` when the
  /// handle is free to claim.
  Future<bool> isUsernameAvailable(String handle) async {
    final response = await _client.dio.get(
      '/users/username-available',
      queryParameters: {'handle': handle},
    );
    return _client.unwrap(
      response,
      (json) => json['available'] as bool,
    );
  }

  /// GET /users/:id — fetch another user's public profile.
  Future<User> getUserById(String id) async {
    final response = await _client.dio.get('/users/$id');
    return _client.unwrap(response, User.fromJson);
  }

  /// PATCH /users/:id — legacy-style user update (name, avatar, DOB,
  /// location). Distinct from [patchMe].
  Future<User> updateUser(String id, UpdateUserDto dto) async {
    final response = await _client.dio.patch(
      '/users/$id',
      data: _stripNulls(dto.toJson()),
    );
    return _client.unwrap(response, User.fromJson);
  }

  /// PATCH /users/:id/preferences — partial update of the user's
  /// notification / privacy / feed-weight preferences. Returns the full
  /// preferences object (not a User).
  Future<Map<String, dynamic>> updatePreferences(
    String id,
    UpdateUserPreferencesDto dto,
  ) async {
    final response = await _client.dio.patch(
      '/users/$id/preferences',
      data: _stripNulls(dto.toJson()),
    );
    final wrapped = response.data as Map<String, dynamic>;
    return wrapped['data'] as Map<String, dynamic>;
  }

  /// Remove `null` values from a DTO JSON map so PATCH requests only carry
  /// fields the caller explicitly set. Nested maps are preserved as-is
  /// (`null` inside them is meaningful — e.g. clearing `dateOfBirth`).
  Map<String, dynamic> _stripNulls(Map<String, dynamic> json) {
    return <String, dynamic>{
      for (final entry in json.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }
}
