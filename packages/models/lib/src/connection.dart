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
