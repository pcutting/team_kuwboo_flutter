import 'package:freezed_annotation/freezed_annotation.dart';

part 'interest.freezed.dart';
part 'interest.g.dart';

/// Declared interest catalogue row. Mirrors
/// `apps/api/src/modules/interests/entities/interest.entity.ts`.
@freezed
abstract class Interest with _$Interest {
  const factory Interest({
    required String id,
    required String slug,
    required String label,
    String? category,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Interest;

  factory Interest.fromJson(Map<String, dynamic> json) =>
      _$InterestFromJson(json);
}

/// Join row recording that a user declared an interest. Mirrors
/// `user-interest.entity.ts`.
@freezed
abstract class UserInterest with _$UserInterest {
  const factory UserInterest({
    required String id,
    required String userId,
    required String interestId,
    required DateTime selectedAt,
  }) = _UserInterest;

  factory UserInterest.fromJson(Map<String, dynamic> json) =>
      _$UserInterestFromJson(json);
}

/// Behavioural interest signal aggregate. Mirrors
/// `interest-signal.entity.ts`.
@freezed
abstract class InterestSignal with _$InterestSignal {
  const factory InterestSignal({
    required String id,
    required String userId,
    required String interestId,
    @Default(0.0) double weight,
    @Default(0) int eventCount,
    required DateTime lastSeenAt,
  }) = _InterestSignal;

  factory InterestSignal.fromJson(Map<String, dynamic> json) =>
      _$InterestSignalFromJson(json);
}
