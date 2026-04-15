/// Consent models. Mirrors
/// `apps/api/src/modules/consent/entities/user-consent.entity.ts` and
/// `grant-consent.dto.ts`.
///
/// Hand-written (no build_runner).
library;

/// Types of consent the platform tracks. Backend values:
/// TERMS, PRIVACY, MARKETING, LOCATION, COOKIES, DATA_SALE_OPT_OUT.
///
/// NOTE: task brief mentioned BIOMETRIC — not in backend. Location and
/// DATA_SALE_OPT_OUT are present instead.
enum ConsentType {
  terms('TERMS'),
  privacy('PRIVACY'),
  marketing('MARKETING'),
  location('LOCATION'),
  cookies('COOKIES'),
  dataSaleOptOut('DATA_SALE_OPT_OUT');

  const ConsentType(this.value);
  final String value;

  static ConsentType fromJson(String value) => ConsentType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown ConsentType: $value'),
      );

  String toJson() => value;
}

/// Where the consent was captured. Required by the backend — wasn't
/// mentioned in the task brief as a separate enum.
enum ConsentSource {
  registration('REGISTRATION'),
  settings('SETTINGS'),
  prompt('PROMPT'),
  legalUpdate('LEGAL_UPDATE');

  const ConsentSource(this.value);
  final String value;

  static ConsentSource fromJson(String value) =>
      ConsentSource.values.firstWhere(
        (e) => e.value == value,
        orElse: () => throw ArgumentError('Unknown ConsentSource: $value'),
      );

  String toJson() => value;
}

/// A single user consent record.
class Consent {
  const Consent({
    required this.id,
    required this.userId,
    required this.type,
    required this.version,
    required this.source,
    required this.grantedAt,
    this.revokedAt,
    this.ip,
  });

  final String id;
  final String userId;

  /// Maps to backend column `consentType`.
  final ConsentType type;
  final String version;
  final ConsentSource source;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  /// Maps to backend column `ipAddress`.
  final String? ip;

  factory Consent.fromJson(Map<String, dynamic> json) {
    return Consent(
      id: json['id'] as String,
      userId: (json['userId'] ?? (json['user'] as Map?)?['id']) as String,
      type: ConsentType.fromJson(
        (json['type'] ?? json['consentType']) as String,
      ),
      version: json['version'] as String,
      source: ConsentSource.fromJson(json['source'] as String),
      grantedAt: DateTime.parse(json['grantedAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      ip: (json['ip'] ?? json['ipAddress']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'consentType': type.toJson(),
        'version': version,
        'source': source.toJson(),
        'grantedAt': grantedAt.toIso8601String(),
        if (revokedAt != null) 'revokedAt': revokedAt!.toIso8601String(),
        if (ip != null) 'ipAddress': ip,
      };
}

/// Request body for `POST /consent`. Backend field name is `consentType`
/// (not `type`). IP is captured server-side from the request.
class GrantConsentDto {
  const GrantConsentDto({
    required this.type,
    required this.version,
    required this.source,
  });

  final ConsentType type;
  final String version;
  final ConsentSource source;

  Map<String, dynamic> toJson() => {
        'consentType': type.toJson(),
        'version': version,
        'source': source.toJson(),
      };
}
