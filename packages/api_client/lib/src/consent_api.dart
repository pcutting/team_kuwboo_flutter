import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Consent endpoints. See API_SURFACE §consent and
/// `apps/api/src/modules/consent/consent.controller.ts`.
class ConsentApi {
  ConsentApi(this._client);

  final KuwbooApiClient _client;

  /// List the authenticated user's active (non-revoked) consents.
  Future<List<Consent>> list() async {
    final response = await _client.dio.get('/consent');
    return _client.unwrapList(response, Consent.fromJson);
  }

  /// Grant a new consent. The backend captures the client IP from the
  /// request, so it is not part of the DTO.
  Future<Consent> grant(GrantConsentDto dto) async {
    final response = await _client.dio.post(
      '/consent',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Consent.fromJson);
  }

  /// Revoke a previously-granted consent. Returns the backend's message.
  Future<String> revoke(ConsentType consentType) async {
    final response = await _client.dio.delete('/consent/${consentType.value}');
    return _client.unwrap(response, (json) => json['message'] as String);
  }
}
