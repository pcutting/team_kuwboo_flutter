import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Sponsored-campaign endpoints. See API_SURFACE §sponsored and
/// `apps/api/src/modules/sponsored/sponsored.controller.ts`.
class SponsoredApi {
  SponsoredApi(this._client);

  final KuwbooApiClient _client;

  /// Create a new campaign (status defaults to DRAFT).
  Future<SponsoredCampaign> createCampaign(CreateCampaignDto dto) async {
    final response = await _client.dio.post(
      '/sponsored/campaigns',
      data: dto.toJson(),
    );
    return _client.unwrap(response, SponsoredCampaign.fromJson);
  }

  /// List campaigns owned by the authenticated advertiser.
  Future<CampaignPage> listMyCampaigns({String? cursor, int limit = 20}) async {
    final response = await _client.dio.get(
      '/sponsored/campaigns',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return _client.unwrap(response, CampaignPage.fromJson);
  }

  /// Transition a campaign between DRAFT/ACTIVE/PAUSED/ENDED. Ownership
  /// is enforced server-side.
  Future<SponsoredCampaign> updateCampaignStatus(
    String id,
    UpdateCampaignStatusDto dto,
  ) async {
    final response = await _client.dio.patch(
      '/sponsored/campaigns/$id',
      data: dto.toJson(),
    );
    return _client.unwrap(response, SponsoredCampaign.fromJson);
  }
}
