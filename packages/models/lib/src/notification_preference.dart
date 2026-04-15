/// Per-module, per-event-type notification preference.
///
/// Client UI renders this as a grid (moduleKey rows x eventType columns)
/// with per-channel (push, in-app) toggles. Matches backend
/// `NotificationPreference` entity.
class NotificationPreference {
  const NotificationPreference({
    required this.id,
    required this.userId,
    required this.moduleKey,
    required this.eventType,
    this.pushEnabled = true,
    this.inAppEnabled = true,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String moduleKey;
  final String eventType;
  final bool pushEnabled;
  final bool inAppEnabled;
  final DateTime createdAt;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    // Backend may nest `user` or expose `userId` directly.
    String userId;
    final u = json['user'];
    if (u is Map<String, dynamic>) {
      userId = u['id'] as String;
    } else {
      userId = (json['userId'] ?? u ?? '') as String;
    }
    return NotificationPreference(
      id: json['id'] as String,
      userId: userId,
      moduleKey: json['moduleKey'] as String,
      eventType: json['eventType'] as String,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'moduleKey': moduleKey,
        'eventType': eventType,
        'pushEnabled': pushEnabled,
        'inAppEnabled': inAppEnabled,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Single preference item for an update request.
class NotificationPreferenceItem {
  const NotificationPreferenceItem({
    required this.moduleKey,
    required this.eventType,
    this.pushEnabled,
    this.inAppEnabled,
  });

  final String moduleKey;
  final String eventType;
  final bool? pushEnabled;
  final bool? inAppEnabled;

  Map<String, dynamic> toJson() => {
        'moduleKey': moduleKey,
        'eventType': eventType,
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (inAppEnabled != null) 'inAppEnabled': inAppEnabled,
      };
}

/// Batch update of notification preferences.
class UpdatePreferencesDto {
  const UpdatePreferencesDto({required this.preferences});

  final List<NotificationPreferenceItem> preferences;

  Map<String, dynamic> toJson() => {
        'preferences': preferences.map((p) => p.toJson()).toList(),
      };
}
