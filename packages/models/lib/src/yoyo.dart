import 'package:freezed_annotation/freezed_annotation.dart';

part 'yoyo.freezed.dart';
part 'yoyo.g.dart';

// ───────────────────────── Enums ─────────────────────────

/// Outcome of a YoYo override: explicit allow (bypass filters) or block.
///
/// Backend enum: `apps/api/src/common/enums/yoyo.enum.ts` (ALLOW / BLOCK).
@JsonEnum(valueField: 'value')
enum OverrideAction {
  allow('ALLOW'),
  block('BLOCK');

  const OverrideAction(this.value);
  final String value;
}

/// Wave lifecycle state.
///
/// Backend enum: `WaveStatus` (PENDING / ACCEPTED / DECLINED / EXPIRED).
@JsonEnum(valueField: 'value')
enum WaveStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  declined('DECLINED'),
  expired('EXPIRED');

  const WaveStatus(this.value);
  final String value;
}

// ───────────────────────── Response models ─────────────────────────

/// A user discovered within proximity range.
///
/// The backend returns `distanceMeters` as an integer (rounded from the
/// PostGIS distance in metres). Consumers that want kilometres can divide
/// by 1000 at the UI layer.
@freezed
abstract class NearbyUser with _$NearbyUser {
  const factory NearbyUser({
    required String id,
    required String name,
    String? avatarUrl,
    @Default(0) int distanceMeters,
    String? onlineStatus,
  }) = _NearbyUser;

  factory NearbyUser.fromJson(Map<String, dynamic> json) =>
      _$NearbyUserFromJson(json);
}

/// User-configurable proximity discovery settings.
///
/// Backend entity: `yoyo_settings`. `radiusKm` is validated 1-500;
/// `ageMin` / `ageMax` validated 13-120. `genderFilter` is a free
/// varchar(20) on the backend (no enum) — clients should treat it as
/// an opaque string.
@freezed
abstract class YoyoSettings with _$YoyoSettings {
  const factory YoyoSettings({
    @Default(true) bool isVisible,
    @Default(10) int radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  }) = _YoyoSettings;

  factory YoyoSettings.fromJson(Map<String, dynamic> json) =>
      _$YoyoSettingsFromJson(json);
}

/// A wave (interest signal) sent between users.
@freezed
abstract class Wave with _$Wave {
  const factory Wave({
    required String id,
    required String fromUserId,
    required String toUserId,
    String? fromUserName,
    String? fromUserAvatar,
    String? message,
    required String status,
    required DateTime createdAt,
  }) = _Wave;

  factory Wave.fromJson(Map<String, dynamic> json) => _$WaveFromJson(json);
}

/// A per-user override that forces ALLOW or BLOCK regardless of the
/// standard YoYo filter stack (visibility, radius, age, gender).
///
/// Backend entity: `yoyo_overrides`, unique on (user, targetUser).
class YoyoOverride {
  const YoyoOverride({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String targetUserId;
  final OverrideAction action;
  final DateTime createdAt;

  factory YoyoOverride.fromJson(Map<String, dynamic> json) {
    // Backend serializes MikroORM ManyToOne as either a nested object with
    // an `id`, or a bare id string depending on populate hints. Normalise.
    String extractId(dynamic raw) {
      if (raw is String) return raw;
      if (raw is Map<String, dynamic>) return raw['id'] as String;
      throw FormatException('Unexpected user reference shape: $raw');
    }

    final actionRaw = json['action'] as String;
    return YoyoOverride(
      id: json['id'] as String,
      userId: extractId(json['user'] ?? json['userId']),
      targetUserId: extractId(json['targetUser'] ?? json['targetUserId']),
      action: OverrideAction.values.firstWhere(
        (e) => e.value == actionRaw,
        orElse: () => throw FormatException('Unknown OverrideAction: $actionRaw'),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'targetUserId': targetUserId,
        'action': action.value,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Server response after accepting/declining a wave.
///
/// When `accept: true`, the backend also creates a messaging Thread
/// between the two users (moduleKey: SOCIAL_STUMBLE). The controller
/// returns the updated [Wave] entity; this wrapper exposes the resulting
/// thread id if the backend begins surfacing it.
class WaveResponse {
  const WaveResponse({required this.wave, this.threadId});

  final Wave wave;
  final String? threadId;

  factory WaveResponse.fromJson(Map<String, dynamic> json) {
    // Backend currently returns the Wave entity directly. Accept either
    // shape: {...wave fields} or {wave: {...}, threadId?: ...}.
    if (json.containsKey('wave')) {
      return WaveResponse(
        wave: Wave.fromJson(json['wave'] as Map<String, dynamic>),
        threadId: json['threadId'] as String?,
      );
    }
    return WaveResponse(wave: Wave.fromJson(json));
  }

  Map<String, dynamic> toJson() => {
        'wave': wave.toJson(),
        if (threadId != null) 'threadId': threadId,
      };
}

// ───────────────────────── Request DTOs ─────────────────────────
//
// These mirror the NestJS DTOs 1:1 so callers can stage mutations
// as typed objects before firing them through [YoyoApi]. Hand-written
// (not Freezed) so adding them doesn't require build_runner.

/// Request body for `POST /yoyo/location`.
///
/// NOTE on naming: the backend DTO uses `latitude` / `longitude` (full
/// words) on the POST body but exposes `lat` / `lng` as query-string
/// params on `GET /yoyo/nearby`. This DTO matches the POST body shape.
class UpdateLocationDto {
  const UpdateLocationDto({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
        'latitude': lat,
        'longitude': lng,
      };
}

/// Request body for `PATCH /yoyo/settings`. All fields optional.
class UpdateYoyoSettingsDto {
  const UpdateYoyoSettingsDto({
    this.isVisible,
    this.radiusKm,
    this.ageMin,
    this.ageMax,
    this.genderFilter,
  });

  final bool? isVisible;
  final int? radiusKm;
  final int? ageMin;
  final int? ageMax;
  final String? genderFilter;

  Map<String, dynamic> toJson() => {
        if (isVisible != null) 'isVisible': isVisible,
        if (radiusKm != null) 'radiusKm': radiusKm,
        if (ageMin != null) 'ageMin': ageMin,
        if (ageMax != null) 'ageMax': ageMax,
        if (genderFilter != null) 'genderFilter': genderFilter,
      };
}

/// Request body for `POST /yoyo/overrides`.
class CreateOverrideDto {
  const CreateOverrideDto({required this.targetUserId, required this.action});

  final String targetUserId;
  final OverrideAction action;

  Map<String, dynamic> toJson() => {
        'targetUserId': targetUserId,
        'action': action.value,
      };
}

/// Request body for `POST /yoyo/wave`.
class SendWaveDto {
  const SendWaveDto({required this.toUserId, this.message});

  final String toUserId;
  final String? message;

  Map<String, dynamic> toJson() => {
        'toUserId': toUserId,
        if (message != null) 'message': message,
      };
}

/// Request body for `POST /yoyo/waves/:id/respond`.
class RespondWaveDto {
  const RespondWaveDto({required this.accept});

  final bool accept;

  Map<String, dynamic> toJson() => {'accept': accept};
}
