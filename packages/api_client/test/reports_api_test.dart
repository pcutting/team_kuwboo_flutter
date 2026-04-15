import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '_test_support.dart';

Map<String, dynamic> _reportJson({
  String id = 'r1',
  String status = 'PENDING',
}) {
  return {
    'id': id,
    'reporterId': 'u1',
    'targetType': 'USER',
    'targetId': 'u2',
    'reason': 'ABUSE',
    'description': 'bad behaviour',
    'status': status,
    'createdAt': '2026-04-15T10:00:00.000Z',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(stubSecureStorage);

  group('ReportsApi', () {
    test('create POSTs to /reports', () async {
      final wired = makeTestClient((_) => {'data': _reportJson()});
      final api = ReportsApi(wired.client);

      final report = await api.create(
        const CreateReportDto(
          targetType: ReportTargetType.user,
          targetId: 'u2',
          reason: ReportReason.abuse,
          description: 'bad behaviour',
        ),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'POST');
      expect(req.path, '/reports');
      expect(req.data, {
        'targetType': 'USER',
        'targetId': 'u2',
        'reason': 'ABUSE',
        'description': 'bad behaviour',
      });
      expect(report.id, 'r1');
      expect(report.reason, ReportReason.abuse);
      expect(report.status, ReportStatus.pending);
    });

    test('listPending GETs with page + limit', () async {
      final wired = makeTestClient((_) => {
            'data': {
              'reports': [_reportJson(id: 'r1'), _reportJson(id: 'r2')],
            },
          });
      final api = ReportsApi(wired.client);

      final page = await api.listPending(page: 2, limit: 50);

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'GET');
      expect(req.path, '/reports');
      expect(req.queryParameters, {'page': 2, 'limit': 50});
      expect(page.reports, hasLength(2));
    });

    test('review PATCHes /reports/:id/review', () async {
      final wired = makeTestClient(
        (_) => {'data': _reportJson(status: 'RESOLVED')},
      );
      final api = ReportsApi(wired.client);

      final result = await api.review(
        'r1',
        const ReviewReportDto(
          status: ReportStatus.resolved,
          notes: 'confirmed',
        ),
      );

      final req = wired.adapter.lastRequest!;
      expect(req.method, 'PATCH');
      expect(req.path, '/reports/r1/review');
      expect(req.data, {'status': 'RESOLVED', 'notes': 'confirmed'});
      expect(result.status, ReportStatus.resolved);
    });

    test('ReviewReportDto asserts status is DISMISSED or RESOLVED', () {
      expect(
        () => ReviewReportDto(status: ReportStatus.pending),
        throwsA(isA<AssertionError>()),
      );
    });

    test('enums cover backend values including MESSAGE/IN_REVIEW/ESCALATED',
        () {
      expect(
        ReportTargetType.fromJson('MESSAGE'),
        ReportTargetType.message,
      );
      expect(ReportStatus.fromJson('IN_REVIEW'), ReportStatus.inReview);
      expect(ReportStatus.fromJson('ESCALATED'), ReportStatus.escalated);
      expect(ReportReason.fromJson('COPYRIGHT'), ReportReason.copyright);
    });
  });
}
