import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'credential.freezed.dart';
part 'credential.g.dart';

/// A verified identity credential attached to a user. Mirrors
/// `apps/api/src/modules/credentials/entities/credential.entity.ts`.
///
/// `userId` is the FK on the wire; MikroORM exposes it as either a populated
/// `user` relation or an unpopulated `user` id scalar depending on query —
/// our list/attach/revoke endpoints return the scalar form.
@freezed
abstract class Credential with _$Credential {
  const factory Credential({
    required String id,
    required String userId,
    required CredentialType type,
    required String identifier,
    Map<String, dynamic>? providerData,
    required DateTime verifiedAt,
    @Default(false) bool isPrimary,
    DateTime? revokedAt,
    required DateTime createdAt,
    DateTime? lastUsedAt,
  }) = _Credential;

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);
}
