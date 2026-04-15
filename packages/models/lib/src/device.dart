import 'enums.dart';

/// A registered FCM device for a user. Matches backend `Device` entity.
///
/// Note: backend column is `lastActiveAt`; this model also accepts `lastSeenAt`
/// as an alias for forward compatibility.
class Device {
  const Device({
    required this.id,
    required this.userId,
    required this.fcmToken,
    required this.platform,
    this.appVersion,
    this.deviceModel,
    this.osVersion,
    this.isActive = true,
    required this.lastSeenAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fcmToken;
  final DevicePlatform platform;
  final String? appVersion;
  final String? deviceModel;
  final String? osVersion;
  final bool isActive;
  final DateTime lastSeenAt;
  final DateTime createdAt;

  factory Device.fromJson(Map<String, dynamic> json) {
    String userId;
    final u = json['user'];
    if (u is Map<String, dynamic>) {
      userId = u['id'] as String;
    } else {
      userId = (json['userId'] ?? u ?? '') as String;
    }

    final platformRaw = json['platform'] as String;
    final platform = DevicePlatform.values.firstWhere(
      (p) => p.value == platformRaw,
      orElse: () => DevicePlatform.android,
    );

    final lastSeenRaw =
        (json['lastSeenAt'] ?? json['lastActiveAt']) as String?;

    return Device(
      id: json['id'] as String,
      userId: userId,
      fcmToken: json['fcmToken'] as String,
      platform: platform,
      appVersion: json['appVersion'] as String?,
      deviceModel: json['deviceModel'] as String?,
      osVersion: json['osVersion'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastSeenAt: lastSeenRaw != null
          ? DateTime.parse(lastSeenRaw)
          : DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fcmToken': fcmToken,
        'platform': platform.value,
        if (appVersion != null) 'appVersion': appVersion,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (osVersion != null) 'osVersion': osVersion,
        'isActive': isActive,
        'lastSeenAt': lastSeenAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Request to register a new FCM device for the current user.
class RegisterDeviceDto {
  const RegisterDeviceDto({
    required this.fcmToken,
    required this.platform,
    this.appVersion,
    this.deviceModel,
    this.osVersion,
  });

  final String fcmToken;
  final DevicePlatform platform;
  final String? appVersion;
  final String? deviceModel;
  final String? osVersion;

  Map<String, dynamic> toJson() => {
        'fcmToken': fcmToken,
        'platform': platform.value,
        if (appVersion != null) 'appVersion': appVersion,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (osVersion != null) 'osVersion': osVersion,
      };
}
