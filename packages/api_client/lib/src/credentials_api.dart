import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Credential (phone / email / Google / Apple) endpoints — §11.
class CredentialsApi {
  CredentialsApi(this._client);

  final KuwbooApiClient _client;

  Future<List<Credential>> list() async {
    final response = await _client.dio.get('/credentials');
    return _client.unwrap(response, (json) {
      final list = (json['credentials'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Credential.fromJson).toList();
    });
  }

  /// Attach a new credential. For `phone` / `email` the caller must first
  /// request an OTP via `AuthApi.sendPhoneOtp` / `sendEmailOtp` and pass
  /// the received [otpCode] here. `google` / `apple` credentials are
  /// attached via the `/auth/{google|apple}` flow and do not use this
  /// endpoint.
  Future<Credential> attach({
    required CredentialType type,
    required String identifier,
    String? otpCode,
  }) async {
    final response = await _client.dio.post(
      '/credentials',
      data: {
        'type': type.value,
        'identifier': identifier,
        if (otpCode != null) 'otp': otpCode,
      },
    );
    return _client.unwrap(
      response,
      (json) =>
          Credential.fromJson(json['credential'] as Map<String, dynamic>),
    );
  }

  Future<void> revoke(String id) async {
    await _client.dio.delete('/credentials/$id');
  }
}
