import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Reports endpoints. See API_SURFACE §reports and
/// `apps/api/src/modules/reports/reports.controller.ts`.
class ReportsApi {
  ReportsApi(this._client);

  final KuwbooApiClient _client;

  /// File a report against a user, content, comment, or message.
  Future<Report> create(CreateReportDto dto) async {
    final response = await _client.dio.post(
      '/reports',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Report.fromJson);
  }

  /// Moderator-only — list pending reports.
  Future<ReportPage> listPending({int? page, int? limit}) async {
    final response = await _client.dio.get(
      '/reports',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return _client.unwrap(response, ReportPage.fromJson);
  }

  /// Moderator-only — resolve or dismiss a report.
  Future<Report> review(String id, ReviewReportDto dto) async {
    final response = await _client.dio.patch(
      '/reports/$id/review',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Report.fromJson);
  }
}
