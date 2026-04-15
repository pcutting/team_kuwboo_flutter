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

/// Request body for `POST /credentials` (IDENTITY_CONTRACT §4.8, §11.2).
///
/// For `phone` / `email` the caller first requests an OTP via
/// `AuthApi.sendPhoneOtp` / `sendEmailOtp` and includes the received code
/// here. `google` / `apple` credentials are attached via
/// `/auth/{google|apple}/confirm`, not via this endpoint.
///
/// Hand-written (not Freezed) so the file can be edited without re-running
/// build_runner; mirrors the wire shape exactly.
class AttachCredentialDto {
  const AttachCredentialDto({
    required this.type,
    required this.identifier,
    this.otp,
  });

  final CredentialType type;
  final String identifier;
  final String? otp;

  Map<String, dynamic> toJson() => {
        'type': type.value,
        'identifier': identifier,
        if (otp != null) 'otp': otp,
      };
}
