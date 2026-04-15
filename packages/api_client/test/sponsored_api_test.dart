import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_test_support.dart';

Map<String, dynamic> _campaignJson({
  String id = 'c1',
  String status = 'DRAFT',
}) {
  return {
    'id': id,
    'advertiserId': 'u1',
    'contentId': 'co1',
    'budgetCents': 5000,
    'spentCents': 0,
    'status': status,
    'targeting': {'country': 'GB'},
    'startsAt': '2026-05-01T00:00:00.000Z',
    'endsAt': '2026-05-31T00:00:00.000Z',
    'createdAt': '2026-04-15T10:00:00.000Z',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(stubSecureStorage);

  group('SponsoredApi', () {
    test('createCampaign POSTs to /sponsored/campaigns', () async {
      final wired = makeTestClient((_) => {'data': _campaignJson()});
      final api = SponsoredApi(wired.client);

      final campaign = await api.createCampaign(
        CreateCampaignDto(
          contentId: 'co1',
          budgetCents: 5000,
          startsAt: DateTime.utc(2026, 5, 1),
          endsAt: DateTime.utc(2026, 5, 31),
          targeting: const {'country': 'GB'},
        ),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/sponsored/campaigns');
      expect((req.data as Map)['contentId'], 'co1');
      expect((req.data as Map)['budgetCents'], 5000);
      expect(campaign.id, 'c1');
      expect(campaign.status, CampaignStatus.draft);
      expect(campaign.targeting, {'country': 'GB'});
    });

    test('listMyCampaigns GETs with cursor + limit', () async {
      final wired = makeTestClient((_) => {
            'data': {
              'items': [_campaignJson(id: 'c1'), _campaignJson(id: 'c2')],
              'nextCursor': 'next-page',
            },
          });
      final api = SponsoredApi(wired.client);

      final page = await api.listMyCampaigns(cursor: 'abc', limit: 10);

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'GET');
      expect(req.path, '/sponsored/campaigns');
      expect(req.queryParameters, {'cursor': 'abc', 'limit': 10});
      expect(page.items, hasLength(2));
      expect(page.nextCursor, 'next-page');
    });

    test('updateCampaignStatus PATCHes status', () async {
      final wired = makeTestClient(
        (_) => {'data': _campaignJson(status: 'ACTIVE')},
      );
      final api = SponsoredApi(wired.client);

      final result = await api.updateCampaignStatus(
        'c1',
        const UpdateCampaignStatusDto(status: CampaignStatus.active),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'PATCH');
      expect(req.path, '/sponsored/campaigns/c1');
      expect(req.data, {'status': 'ACTIVE'});
      expect(result.status, CampaignStatus.active);
    });

    test('CampaignStatus covers DRAFT/ACTIVE/PAUSED/ENDED', () {
      expect(CampaignStatus.fromJson('DRAFT'), CampaignStatus.draft);
      expect(CampaignStatus.fromJson('ACTIVE'), CampaignStatus.active);
      expect(CampaignStatus.fromJson('PAUSED'), CampaignStatus.paused);
      expect(CampaignStatus.fromJson('ENDED'), CampaignStatus.ended);
    });
  });
}
