import 'package:freezed_annotation/freezed_annotation.dart';

part 'yoyo.freezed.dart';
part 'yoyo.g.dart';

/// A user discovered within proximity range.
@freezed
abstract class NearbyUser with _$NearbyUser {
  const factory NearbyUser({
    required String id,
    required String name,
    String? avatarUrl,
    required double distanceKm,
    String? onlineStatus,
  }) = _NearbyUser;

  factory NearbyUser.fromJson(Map<String, dynamic> json) =>
      _$NearbyUserFromJson(json);
}

/// User-configurable proximity discovery settings.
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
