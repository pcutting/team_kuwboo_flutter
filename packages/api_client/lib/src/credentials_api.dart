import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Credential (phone / email / Google / Apple) endpoints.
///
/// Mirrors IDENTITY_CONTRACT §11.2 (user-scoped) and §11.5 (admin-scoped).
/// Five routes total: 3 user + 2 admin.
///
/// Invariants encoded here that the backend also enforces (§11.2):
/// - A user cannot revoke their last active credential — the backend
///   responds `409 {code: "last_credential"}`. The client surfaces that
///   error unchanged; the UI layer is responsible for the friendly copy.
/// - Attaching a credential whose `(type, identifier)` is already in use by
///   a different user responds `409 {code: "credential_in_use"}` — again
///   surfaced as-is (no silent merge; see §2 guiding principle #5).
/// - Deleting a primary credential promotes the oldest remaining
///   credential of the same type to primary server-side; the client just
///   re-fetches via [listMine] to see the new state.
class CredentialsApi {
  CredentialsApi(this._client);

  final KuwbooApiClient _client;

  // ---- User-scoped (§11.2) ----

  /// `GET /credentials` — active + revoked credentials for the caller.
  Future<List<Credential>> listMine() async {
    final response = await _client.dio.get('/credentials');
    return _client.unwrap(response, (json) {
      final list = (json['credentials'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Credential.fromJson).toList();
    });
  }

  /// `POST /credentials` — attach a new credential to the caller.
  ///
  /// For phone / email, [AttachCredentialDto.otp] MUST carry a code from a
  /// prior `auth/{phone|email}/send-otp` call. For google / apple the
  /// attach path is `/auth/{provider}/confirm` instead (§4.5–4.6); callers
  /// should not use this endpoint for SSO credentials.
  Future<Credential> attach(AttachCredentialDto dto) async {
    final response = await _client.dio.post('/credentials', data: dto.toJson());
    return _client.unwrap(
      response,
      (json) =>
          Credential.fromJson(json['credential'] as Map<String, dynamic>),
    );
  }

  /// `DELETE /credentials/:id` — revoke one of the caller's credentials.
  ///
  /// Returns 204 on success. Backend rejects with `409 last_credential` if
  /// [id] is the caller's only active credential (see class docs).
  Future<void> revoke(String id) async {
    await _client.dio.delete('/credentials/$id');
  }

  // ---- Admin-scoped (§11.5) ----
  // Require a JWT with `role=admin`; the server enforces via @AdminGuard.

  /// Admin: `GET /admin/users/:userId/credentials` — full credential list
  /// (includes revoked rows) for a target user. Audit surface.
  Future<List<Credential>> adminListUserCredentials(String userId) async {
    final response =
        await _client.dio.get('/admin/users/$userId/credentials');
    return _client.unwrap(response, (json) {
      final list = (json['credentials'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Credential.fromJson).toList();
    });
  }

  /// Admin: `POST /admin/credentials/:credentialId/revoke` — force-revoke
  /// a credential (e.g. stolen phone). [reason] is logged on the admin
  /// audit row. `userId` is accepted only for symmetry with the other
  /// admin helpers; the backend identifies the target by credential id.
  Future<Credential> adminRevokeUserCredential(
    String userId,
    String credentialId, {
    String? reason,
  }) async {
    final response = await _client.dio.post(
      '/admin/credentials/$credentialId/revoke',
      data: {if (reason != null) 'reason': reason},
    );
    return _client.unwrap(
      response,
      (json) =>
          Credential.fromJson(json['credential'] as Map<String, dynamic>),
    );
  }
}
