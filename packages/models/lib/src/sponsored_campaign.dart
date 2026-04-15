/// Sponsored campaign models. Mirrors
/// `apps/api/src/modules/sponsored/entities/sponsored-campaign.entity.ts`
/// and `create-campaign.dto.ts` / `update-campaign-status.dto.ts`.
///
/// Hand-written (no build_runner) — see task note.
library;

/// Lifecycle status for an advertiser's sponsored campaign.
///
/// Backend uses `ENDED` (not `COMPLETED`) as the terminal state.
enum CampaignStatus {
  draft('DRAFT'),
  active('ACTIVE'),
  paused('PAUSED'),
  ended('ENDED');

  const CampaignStatus(this.value);
  final String value;

  static CampaignStatus fromJson(String value) =>
      CampaignStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown CampaignStatus: $value'),
      );

  String toJson() => value;
}

/// A sponsored campaign owned by an advertiser.
class SponsoredCampaign {
  const SponsoredCampaign({
    required this.id,
    required this.advertiserId,
    required this.contentId,
    required this.budgetCents,
    required this.spentCents,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
    this.targeting,
    this.updatedAt,
  });

  final String id;
  final String advertiserId;
  final String contentId;
  final int budgetCents;
  final int spentCents;
  final CampaignStatus status;
  final Map<String, dynamic>? targeting;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SponsoredCampaign.fromJson(Map<String, dynamic> json) {
    return SponsoredCampaign(
      id: json['id'] as String,
      advertiserId:
          (json['advertiserId'] ?? json['advertiser_id'] ?? json['advertiser'])
              as String,
      contentId:
          (json['contentId'] ?? json['content_id'] ?? json['content']) as String,
      budgetCents: (json['budgetCents'] as num).toInt(),
      spentCents: ((json['spentCents'] ?? 0) as num).toInt(),
      status: CampaignStatus.fromJson(json['status'] as String),
      targeting: (json['targeting'] as Map?)?.cast<String, dynamic>(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'advertiserId': advertiserId,
        'contentId': contentId,
        'budgetCents': budgetCents,
        'spentCents': spentCents,
        'status': status.toJson(),
        if (targeting != null) 'targeting': targeting,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}

/// Request body for `POST /sponsored/campaigns`. Backend enforces
/// `budgetCents >= 100`.
class CreateCampaignDto {
  const CreateCampaignDto({
    required this.contentId,
    required this.budgetCents,
    required this.startsAt,
    required this.endsAt,
    this.targeting,
  });

  final String contentId;
  final int budgetCents;
  final DateTime startsAt;
  final DateTime endsAt;
  final Map<String, dynamic>? targeting;

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'budgetCents': budgetCents,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        if (targeting != null) 'targeting': targeting,
      };
}

/// Request body for `PATCH /sponsored/campaigns/:id`.
class UpdateCampaignStatusDto {
  const UpdateCampaignStatusDto({required this.status});

  final CampaignStatus status;

  Map<String, dynamic> toJson() => {'status': status.toJson()};
}

/// Cursor-paginated list of campaigns returned by
/// `GET /sponsored/campaigns`.
class CampaignPage {
  const CampaignPage({required this.items, this.nextCursor});

  final List<SponsoredCampaign> items;
  final String? nextCursor;

  factory CampaignPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return CampaignPage(
      items: raw.map(SponsoredCampaign.fromJson).toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
