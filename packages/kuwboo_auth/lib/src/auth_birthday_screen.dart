import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_step_chip.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

class AuthBirthdayScreen extends StatefulWidget {
  const AuthBirthdayScreen({super.key});

  @override
  State<AuthBirthdayScreen> createState() => _AuthBirthdayScreenState();
}

class _AuthBirthdayScreenState extends State<AuthBirthdayScreen> {
  // Default position: ~18 years ago
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now.day - 1;
    _selectedMonth = now.month - 1;
    _selectedYear = 18; // index 18 = 18 years ago from current year
    _dayController = FixedExtentScrollController(initialItem: _selectedDay);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear);
    // ListWheelScrollView doesn't always fire `onSelectedItemChanged` for its
    // initial item, so the central "selected" label can lag until first scroll.
    // Force a single rebuild after layout to show the initial selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _currentYear => DateTime.now().year;

  bool get _isUnder13 {
    final birthYear = _currentYear - _selectedYear;
    final now = DateTime.now();
    final birthDate = DateTime(birthYear, _selectedMonth + 1, _selectedDay + 1);
    final age = now.difference(birthDate).inDays ~/ 365;
    return age < 13;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          color: theme.surface,
          child: Column(
            children: [
              ProtoSubBar(title: ''),
              const StepChip(step: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "When's your birthday?",
                        style: theme.headline.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your birthday won't be shown publicly.",
                        style: theme.body.copyWith(color: theme.textSecondary),
                      ),
                      const SizedBox(height: 36),

                      // Date picker wheels
                      SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            // Day
                            Expanded(
                              flex: 2,
                              child: _WheelColumn(
                                identifier: AuthIds.birthdayWheelDay,
                                currentValue: '${_selectedDay + 1}',
                                controller: _dayController,
                                itemCount: 31,
                                labelBuilder: (i) => '${i + 1}',
                                onChanged: (i) =>
                                    setState(() => _selectedDay = i),
                              ),
                            ),
                            // Month
                            Expanded(
                              flex: 3,
                              child: _WheelColumn(
                                identifier: AuthIds.birthdayWheelMonth,
                                currentValue: _months[_selectedMonth],
                                controller: _monthController,
                                itemCount: 12,
                                labelBuilder: (i) => _months[i],
                                onChanged: (i) =>
                                    setState(() => _selectedMonth = i),
                              ),
                            ),
                            // Year
                            Expanded(
                              flex: 2,
                              child: _WheelColumn(
                                identifier: AuthIds.birthdayWheelYear,
                                currentValue: '${_currentYear - _selectedYear}',
                                controller: _yearController,
                                itemCount: 100,
                                labelBuilder: (i) => '${_currentYear - i}',
                                onChanged: (i) =>
                                    setState(() => _selectedYear = i),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Continue button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Semantics(
                          identifier: AuthIds.birthdayContinue,
                          button: true,
                          label: 'Continue',
                          child: GestureDetector(
                            onTap: () => _onContinue(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.primary,
                                borderRadius: BorderRadius.circular(
                                  theme.radiusFull,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Continue',
                                  style: theme.button.copyWith(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Alternatives row — three low-emphasis chips that
                      // each open a confirmation sheet explaining the
                      // trade-off before committing. Wraps onto two
                      // lines on narrow devices so labels stay legible.
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28, top: 4),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DobChoiceChip(
                              identifier:
                                  AuthIds.birthdayChipPreferNotToSay,
                              label: 'I prefer not to say',
                              onTap: () => _openChoiceSheet(
                                context,
                                AuthDobChoice.preferNotToSay,
                              ),
                            ),
                            _DobChoiceChip(
                              identifier:
                                  AuthIds.birthdayChipAdultSelfDeclared,
                              label: "I'm 18+",
                              onTap: () => _openChoiceSheet(
                                context,
                                AuthDobChoice.adultSelfDeclared,
                              ),
                            ),
                            _DobChoiceChip(
                              identifier: AuthIds.birthdayChipSkip,
                              label: 'Skip for now',
                              onTap: () => _openChoiceSheet(
                                context,
                                AuthDobChoice.skipped,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openChoiceSheet(
    BuildContext context,
    AuthDobChoice choice,
  ) async {
    final copy = _dobChoiceCopy(choice);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _DobChoiceSheet(copy: copy),
    );
    if (confirmed != true || !mounted) return;
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSaveDobChoice != null) {
      // Best-effort save — same pattern as onSaveBirthday. Never block
      // navigation on a backend write that may not have an endpoint
      // wired up yet (see auth_callbacks.dart for the TODO note).
      unawaited(
        callbacks!.onSaveDobChoice!(choice).catchError((Object e) {
          debugPrint('[birthday] dob choice save failed: $e');
        }),
      );
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authProfile);
  }

  Future<void> _onContinue(BuildContext context) async {
    if (_isUnder13) {
      context.go(ProtoRoutes.authAgeBlock);
      return;
    }
    final dob = DateTime(
      _currentYear - _selectedYear,
      _selectedMonth + 1,
      _selectedDay + 1,
    );
    final callbacks = AuthCallbacksScope.maybeOf(context);
    // Best-effort save — never block onboarding navigation on a backend write.
    // Profile is editable later; the local _isUnder13 gate above is what
    // actually matters for compliance.
    if (callbacks?.onSaveBirthday != null) {
      unawaited(
        callbacks!.onSaveBirthday!(dob).catchError((Object e) {
          debugPrint('[birthday] save failed (will retry on next patch): $e');
        }),
      );
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authProfile);
  }
}

// ─── DOB choice chips + confirm sheet ─────────────────────────────────

class _DobSheetCopy {
  const _DobSheetCopy({
    required this.title,
    required this.body,
    required this.confirmLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;
}

_DobSheetCopy _dobChoiceCopy(AuthDobChoice choice) {
  switch (choice) {
    case AuthDobChoice.preferNotToSay:
      return const _DobSheetCopy(
        title: 'Keep your birthday private?',
        body:
            'We respect your privacy. This locks dating, age-gated content, '
            'and lowers your credibility score — but we record that you '
            "chose not to share, not that you forgot.",
        confirmLabel: 'Confirm',
      );
    case AuthDobChoice.adultSelfDeclared:
      return const _DobSheetCopy(
        title: "Confirm you're an adult",
        body:
            "By tapping confirm, you're telling us you're 18 or older. "
            'We trust you, but dating matches and the verified badge '
            'still need an exact birthday. You can add it later in '
            'Settings.',
        confirmLabel: "I'm 18+",
      );
    case AuthDobChoice.skipped:
      return const _DobSheetCopy(
        title: 'Skip your birthday?',
        body:
            'You can add it later. Until you do, dating, age-rated content, '
            'and premium visibility stay locked, and your credibility '
            'score will be low.',
        confirmLabel: 'Skip anyway',
      );
  }
}

class _DobChoiceChip extends StatelessWidget {
  const _DobChoiceChip({
    required this.identifier,
    required this.label,
    required this.onTap,
  });

  final String identifier;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Semantics(
      identifier: identifier,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.text.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(theme.radiusFull),
            border: Border.all(
              color: theme.text.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: theme.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DobChoiceSheet extends StatelessWidget {
  const _DobChoiceSheet({required this.copy});

  final _DobSheetCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.text.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            copy.title,
            style: theme.headline.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            copy.body,
            style: theme.body.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  identifier: AuthIds.birthdaySheetCancel,
                  button: true,
                  label: 'Go back',
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius:
                            BorderRadius.circular(theme.radiusFull),
                        border: Border.all(
                          color: theme.text.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Go back',
                          style: theme.button.copyWith(
                            fontSize: 15,
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  identifier: AuthIds.birthdaySheetConfirm,
                  button: true,
                  label: copy.confirmLabel,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius:
                            BorderRadius.circular(theme.radiusFull),
                      ),
                      child: Center(
                        child: Text(
                          copy.confirmLabel,
                          style: theme.button.copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final String identifier;
  final String currentValue;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.identifier,
    required this.currentValue,
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Semantics(
      identifier: identifier,
      value: currentValue,
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Wheel
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                return Center(
                  child: Text(
                    labelBuilder(index),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.text,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
