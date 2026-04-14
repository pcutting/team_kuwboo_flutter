import 'package:freezed_annotation/freezed_annotation.dart';

part 'trust_signal.freezed.dart';
part 'trust_signal.g.dart';

/// Append-only trust signal row. `signalType` is a free-text varchar on the
/// backend (see `trust-signal.entity.ts`) — the values emitted by the
/// identity subsystem are documented in the [TrustSignalType] enum, but
/// moderation / future subsystems may append other strings.
@freezed
abstract class TrustSignal with _$TrustSignal {
  const factory TrustSignal({
    required String id,
    required String userId,
    required String signalType,
    required int delta,
    String? source,
    String? reason,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    required DateTime createdAt,
  }) = _TrustSignal;

  factory TrustSignal.fromJson(Map<String, dynamic> json) =>
      _$TrustSignalFromJson(json);
}
