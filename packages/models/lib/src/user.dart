import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    String? phone,
    String? email,
    String? name,
    String? avatarUrl,
    @Default(Role.user) Role role,
    @Default(UserStatus.active) UserStatus status,
    @Default(OnlineStatus.offline) OnlineStatus onlineStatus,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
