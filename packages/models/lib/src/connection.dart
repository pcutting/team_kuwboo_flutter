import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'connection.freezed.dart';
part 'connection.g.dart';

@freezed
abstract class Connection with _$Connection {
  const factory Connection({
    required String id,
    required String fromUserId,
    required String toUserId,
    required ConnectionContext context,
    @Default(ConnectionStatus.pending) ConnectionStatus status,
    ModuleScope? moduleScope,
    required DateTime createdAt,
  }) = _Connection;

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);
}

/// Request payload for follow / friend-request creation.
///
/// Hand-written (no build_runner).
class FollowDto {
  const FollowDto({required this.userId, this.moduleScope});

  final String userId;
  final ModuleScope? moduleScope;

  Map<String, dynamic> toJson() => {
        'targetUserId': userId,
        if (moduleScope != null) 'moduleScope': moduleScope!.value,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowDto &&
          other.userId == userId &&
          other.moduleScope == moduleScope);

  @override
  int get hashCode => Object.hash(userId, moduleScope);
}

/// Request payload for blocking a user.
class BlockDto {
  const BlockDto({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() => {'targetUserId': userId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockDto && other.userId == userId);

  @override
  int get hashCode => userId.hashCode;
}

/// Friend request envelope returned by list/accept/reject endpoints.
///
/// Hand-written immutable class (no build_runner). Mirrors the Freezed
/// shape: unnamed positional-via-named fields, `fromJson`, `==`, `hashCode`.
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        id: json['id'] as String,
        fromUserId: json['fromUserId'] as String,
        toUserId: json['toUserId'] as String,
        status: ConnectionStatus.values.firstWhere(
          (s) => s.value == json['status'],
          orElse: () => ConnectionStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String fromUserId;
  final String toUserId;
  final ConnectionStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': status.value,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendRequest &&
          other.id == id &&
          other.fromUserId == fromUserId &&
          other.toUserId == toUserId &&
          other.status == status &&
          other.createdAt == createdAt);

  @override
  int get hashCode =>
      Object.hash(id, fromUserId, toUserId, status, createdAt);
}
