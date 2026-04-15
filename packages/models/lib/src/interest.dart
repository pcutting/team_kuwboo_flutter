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

/// Request body for `POST /users/me/interests` — replaces the authenticated
/// user's declared interest set. See IDENTITY_CONTRACT §11.3.
///
/// Hand-written to avoid a build_runner round-trip.
class SelectInterestsDto {
  const SelectInterestsDto({required this.interestIds});

  final List<String> interestIds;

  Map<String, dynamic> toJson() => {'interest_ids': interestIds};
}

/// Request body for `POST /admin/interests` (IDENTITY_CONTRACT §11.5).
class CreateInterestDto {
  const CreateInterestDto({
    required this.slug,
    required this.label,
    this.category,
    this.displayOrder = 0,
  });

  final String slug;
  final String label;
  final String? category;
  final int displayOrder;

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'label': label,
        if (category != null) 'category': category,
        'display_order': displayOrder,
      };
}

/// Partial request body for `PATCH /admin/interests/:id`.
///
/// All fields are optional; only non-null fields are sent on the wire.
class UpdateInterestDto {
  const UpdateInterestDto({
    this.slug,
    this.label,
    this.category,
    this.displayOrder,
    this.isActive,
  });

  final String? slug;
  final String? label;
  final String? category;
  final int? displayOrder;
  final bool? isActive;

  Map<String, dynamic> toJson() => {
        if (slug != null) 'slug': slug,
        if (label != null) 'label': label,
        if (category != null) 'category': category,
        if (displayOrder != null) 'display_order': displayOrder,
        if (isActive != null) 'is_active': isActive,
      };
}

/// Request body for `POST /admin/interests/reorder` — bulk updates
/// `display_order` across the active taxonomy. `orderedIds[i]` gets
/// `display_order = i`.
class ReorderInterestsDto {
  const ReorderInterestsDto({required this.orderedIds});

  final List<String> orderedIds;

  Map<String, dynamic> toJson() => {'ordered_ids': orderedIds};
}
