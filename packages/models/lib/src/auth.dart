import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

/// Standard successful authentication envelope returned by phone/email OTP
/// verification and SSO (Google / Apple) flows.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required User user,
    @Default(false) bool isNewUser,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
abstract class TokenPair with _$TokenPair {
  const factory TokenPair({
    required String accessToken,
    required String refreshToken,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
}

/// Body returned with a 409 Conflict from `/auth/google` or `/auth/apple`
/// when the SSO identity resolves to an email already bound to an existing
/// account. The client must send the OTP back via `/auth/{google|apple}/
/// confirm` together with the original `idToken` and the `challengeId`.
///
/// Shape per `auth.controller.ts` `unwrapChallenge`:
/// ```json
/// { "code": "email_owned",
///   "challenge_id": "<uuid>",
///   "email": "user@example.com",
///   "require_verify_email": true }
/// ```
@freezed
abstract class PendingSsoChallenge with _$PendingSsoChallenge {
  const factory PendingSsoChallenge({
    required String code,
    @JsonKey(name: 'challenge_id') required String challengeId,
    required String email,
    @Default(true)
    @JsonKey(name: 'require_verify_email')
    bool requireVerifyEmail,
  }) = _PendingSsoChallenge;

  factory PendingSsoChallenge.fromJson(Map<String, dynamic> json) =>
      _$PendingSsoChallengeFromJson(json);
}
