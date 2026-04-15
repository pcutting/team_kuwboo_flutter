import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_test_support.dart';

Map<String, dynamic> _consentJson({String type = 'TERMS'}) {
  return {
    'id': 'cn1',
    'userId': 'u1',
    'consentType': type,
    'version': '1.0',
    'source': 'REGISTRATION',
    'grantedAt': '2026-04-15T10:00:00.000Z',
    'ipAddress': '127.0.0.1',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(stubSecureStorage);

  group('ConsentApi', () {
    test('list GETs /consent and returns List<Consent>', () async {
      final wired = makeTestClient((_) => {
            'data': [_consentJson(type: 'TERMS'), _consentJson(type: 'PRIVACY')],
          });
      final api = ConsentApi(wired.client);

      final consents = await api.list();

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'GET');
      expect(req.path, '/consent');
      expect(consents, hasLength(2));
      expect(consents.first.type, ConsentType.terms);
      expect(consents.first.source, ConsentSource.registration);
      expect(consents.first.ip, '127.0.0.1');
    });

    test('grant POSTs to /consent with consentType/version/source', () async {
      final wired = makeTestClient((_) => {'data': _consentJson()});
      final api = ConsentApi(wired.client);

      final consent = await api.grant(
        const GrantConsentDto(
          type: ConsentType.terms,
          version: '1.0',
          source: ConsentSource.registration,
        ),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/consent');
      expect(req.data, {
        'consentType': 'TERMS',
        'version': '1.0',
        'source': 'REGISTRATION',
      });
      expect(consent.type, ConsentType.terms);
    });

    test('revoke DELETEs /consent/:type and returns message', () async {
      final wired = makeTestClient(
        (_) => {'data': {'message': 'Consent revoked'}},
      );
      final api = ConsentApi(wired.client);

      final msg = await api.revoke(ConsentType.marketing);

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'DELETE');
      expect(req.path, '/consent/MARKETING');
      expect(msg, 'Consent revoked');
    });

    test('ConsentType covers backend values (incl. DATA_SALE_OPT_OUT)', () {
      expect(ConsentType.fromJson('TERMS'), ConsentType.terms);
      expect(ConsentType.fromJson('PRIVACY'), ConsentType.privacy);
      expect(ConsentType.fromJson('MARKETING'), ConsentType.marketing);
      expect(ConsentType.fromJson('LOCATION'), ConsentType.location);
      expect(ConsentType.fromJson('COOKIES'), ConsentType.cookies);
      expect(
        ConsentType.fromJson('DATA_SALE_OPT_OUT'),
        ConsentType.dataSaleOptOut,
      );
    });
  });
}
