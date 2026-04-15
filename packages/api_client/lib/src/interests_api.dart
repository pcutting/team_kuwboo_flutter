import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Declared-interest endpoints.
///
/// Mirrors IDENTITY_CONTRACT §11.3 (user) and §11.4 (public catalogue) and
/// the admin surface in §11.5. User routes operate on `user_interests`
/// (declared selections); admin routes manage the `interests` taxonomy.
///
/// The reorder endpoint (`POST /admin/interests/reorder`) is a bulk-update
/// convenience over `display_order` — individual rows can also be
/// reordered via `adminUpdate` one at a time.
class InterestsApi {
  InterestsApi(this._client);

  final KuwbooApiClient _client;

  // ---- Public + user-scoped (§11.3–11.4) ----

  /// `GET /interests` — public taxonomy read. Returns active interests
  /// only, sorted by `display_order`.
  Future<List<Interest>> listAll() async {
    final response = await _client.dio.get('/interests');
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// `GET /users/me/interests` — the caller's declared selections.
  Future<List<Interest>> listMine() async {
    final response = await _client.dio.get('/users/me/interests');
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// `POST /users/me/interests` — replace the caller's declared selection
  /// with [dto.interestIds]. The server returns the resulting full set.
  Future<List<Interest>> selectMany(SelectInterestsDto dto) async {
    final response = await _client.dio.post(
      '/users/me/interests',
      data: dto.toJson(),
    );
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// `DELETE /users/me/interests/:id` — drop a single declared interest.
  Future<void> deselectOne(String id) async {
    await _client.dio.delete('/users/me/interests/$id');
  }

  // ---- Admin-scoped (§11.5) ----

  /// Admin: `GET /admin/interests` — taxonomy list (includes soft-deleted
  /// rows, i.e. `is_active = false`).
  Future<List<Interest>> adminListAll() async {
    final response = await _client.dio.get('/admin/interests');
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// Admin: `POST /admin/interests` — create a taxonomy row.
  Future<Interest> adminCreate(CreateInterestDto dto) async {
    final response =
        await _client.dio.post('/admin/interests', data: dto.toJson());
    return _client.unwrap(
      response,
      (json) => Interest.fromJson(json['interest'] as Map<String, dynamic>),
    );
  }

  /// Admin: `PATCH /admin/interests/:id` — partial update. Pass only the
  /// fields being changed; omitted fields stay as-is.
  Future<Interest> adminUpdate(String id, UpdateInterestDto dto) async {
    final response =
        await _client.dio.patch('/admin/interests/$id', data: dto.toJson());
    return _client.unwrap(
      response,
      (json) => Interest.fromJson(json['interest'] as Map<String, dynamic>),
    );
  }

  /// Admin: `DELETE /admin/interests/:id` — soft-delete
  /// (`is_active = false`). Declared `user_interests` referencing the row
  /// are kept so that re-activating the interest restores all signals.
  Future<void> adminDelete(String id) async {
    await _client.dio.delete('/admin/interests/$id');
  }

  /// Admin: `POST /admin/interests/reorder` — bulk reorder. `orderedIds[i]`
  /// is written to `display_order = i`; ids omitted from the list are not
  /// touched.
  Future<List<Interest>> adminReorder(ReorderInterestsDto dto) async {
    final response = await _client.dio.post(
      '/admin/interests/reorder',
      data: dto.toJson(),
    );
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }
}
