/// Report models. Mirrors
/// `apps/api/src/modules/reports/entities/report.entity.ts` and the inline
/// `CreateReportDto` / `ReviewReportDto` in `reports.controller.ts`.
///
/// Hand-written (no build_runner).
library;

/// Target type for a user-filed report. Backend also supports `MESSAGE`
/// in addition to the three listed in the task brief.
enum ReportTargetType {
  user('USER'),
  content('CONTENT'),
  comment('COMMENT'),
  message('MESSAGE');

  const ReportTargetType(this.value);
  final String value;

  static ReportTargetType fromJson(String value) =>
      ReportTargetType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown ReportTargetType: $value'),
      );

  String toJson() => value;
}

/// Reason the reporter selected.
///
/// NOTE: backend values differ from the task brief (no `HARASSMENT` /
/// `EXPLICIT`). Actual values: SPAM, ABUSE, ILLEGAL, INAPPROPRIATE,
/// MISLEADING, COPYRIGHT.
enum ReportReason {
  spam('SPAM'),
  abuse('ABUSE'),
  illegal('ILLEGAL'),
  inappropriate('INAPPROPRIATE'),
  misleading('MISLEADING'),
  copyright('COPYRIGHT');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromJson(String value) =>
      ReportReason.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown ReportReason: $value'),
      );

  String toJson() => value;
}

/// Moderation lifecycle status. Backend also supports `IN_REVIEW` and
/// `ESCALATED` (task brief only listed 3).
enum ReportStatus {
  pending('PENDING'),
  inReview('IN_REVIEW'),
  dismissed('DISMISSED'),
  resolved('RESOLVED'),
  escalated('ESCALATED');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromJson(String value) =>
      ReportStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown ReportStatus: $value'),
      );

  String toJson() => value;
}

/// A user-filed report against a user, content, comment, or message.
class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.description,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  final String id;
  final String reporterId;
  final ReportTargetType targetType;

  /// ID of the reported user/content/comment/message. Backend stores this
  /// in separate FK columns (`reportedUser`/`reportedContent`/`reportedComment`);
  /// the serializer is expected to normalise them to a single `targetId`.
  final String targetId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  /// Backend column name is `reviewNotes`; DTO names it `notes`. Both accepted.
  final String? reviewNotes;
  final DateTime createdAt;

  factory Report.fromJson(Map<String, dynamic> json) {
    // Backend stores three nullable FKs; synthesise a single targetId.
    String? target = json['targetId'] as String?;
    target ??= (json['reportedUser'] as Map?)?['id'] as String?;
    target ??= (json['reportedContent'] as Map?)?['id'] as String?;
    target ??= (json['reportedComment'] as Map?)?['id'] as String?;
    target ??= json['reportedUserId'] as String?;
    target ??= json['reportedContentId'] as String?;
    target ??= json['reportedCommentId'] as String?;

    return Report(
      id: json['id'] as String,
      reporterId:
          (json['reporterId'] ?? (json['reporter'] as Map?)?['id']) as String,
      targetType: ReportTargetType.fromJson(json['targetType'] as String),
      targetId: target ?? '',
      reason: ReportReason.fromJson(json['reason'] as String),
      description: json['description'] as String?,
      status: ReportStatus.fromJson(json['status'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewNotes: (json['reviewNotes'] ?? json['notes']) as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporterId': reporterId,
        'targetType': targetType.toJson(),
        'targetId': targetId,
        'reason': reason.toJson(),
        if (description != null) 'description': description,
        'status': status.toJson(),
        if (reviewedBy != null) 'reviewedBy': reviewedBy,
        if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
        if (reviewNotes != null) 'reviewNotes': reviewNotes,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Request body for `POST /reports`. Description is capped at 1000 chars
/// by the backend.
class CreateReportDto {
  const CreateReportDto({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
  });

  final ReportTargetType targetType;
  final String targetId;
  final ReportReason reason;
  final String? description;

  Map<String, dynamic> toJson() => {
        'targetType': targetType.toJson(),
        'targetId': targetId,
        'reason': reason.toJson(),
        if (description != null) 'description': description,
      };
}

/// Request body for `PATCH /reports/:id/review` (moderator only).
/// Backend restricts `status` to `DISMISSED` or `RESOLVED`.
class ReviewReportDto {
  const ReviewReportDto({required this.status, this.notes})
      : assert(
          status == ReportStatus.dismissed || status == ReportStatus.resolved,
          'Review status must be DISMISSED or RESOLVED',
        );

  final ReportStatus status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
        if (notes != null) 'notes': notes,
      };
}

/// Paginated list returned by `GET /reports` (moderator only).
class ReportPage {
  const ReportPage({required this.reports});

  final List<Report> reports;

  factory ReportPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['reports'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return ReportPage(reports: raw.map(Report.fromJson).toList());
  }
}
