import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Small "Step X of N" pill shown at the top of each onboarding screen (just
/// below `ProtoSubBar`). Gives the user a sense of how far through the
/// sign-up flow they are. The six-step flow is:
///
///   1. method    — pick phone/email/SSO
///   2. phone     — phone or email tab
///   3. otp       — 6-digit verification
///   4. birthday  — date of birth wheel picker
///   5. profile   — display name + username
///   6. tutorial  — 4-page gesture walkthrough
///
/// Keeping the chip here (instead of inlining six near-identical pills) means
/// the styling, spacing, and copy stay consistent if we tune them later.
class StepChip extends StatelessWidget {
  const StepChip({
    super.key,
    required this.step,
    this.total = 6,
    this.almostDone = false,
  });

  /// 1-based step index. Must be between 1 and [total] inclusive.
  final int step;

  /// Total number of steps in the flow.
  final int total;

  /// When true, renders "Almost done" instead of "Step X of N". Used for the
  /// final tutorial screen so the user feels the end approaching rather than
  /// being told they're at step 6 with no hint that 6 is the last.
  final bool almostDone;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.text.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(theme.radiusFull),
          ),
          child: Text(
            almostDone ? 'Almost done' : 'Step $step of $total',
            style: theme.caption.copyWith(
              fontSize: 11,
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
