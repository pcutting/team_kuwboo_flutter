import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'auth_callbacks.dart';

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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
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

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(title: ''),
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
                            controller: _dayController,
                            itemCount: 31,
                            labelBuilder: (i) => '${i + 1}',
                            onChanged: (i) => setState(() => _selectedDay = i),
                          ),
                        ),
                        // Month
                        Expanded(
                          flex: 3,
                          child: _WheelColumn(
                            controller: _monthController,
                            itemCount: 12,
                            labelBuilder: (i) => _months[i],
                            onChanged: (i) => setState(() => _selectedMonth = i),
                          ),
                        ),
                        // Year
                        Expanded(
                          flex: 2,
                          child: _WheelColumn(
                            controller: _yearController,
                            itemCount: 100,
                            labelBuilder: (i) => '${_currentYear - i}',
                            onChanged: (i) => setState(() => _selectedYear = i),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: GestureDetector(
                      onTap: () => _onContinue(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(theme.radiusFull),
                        ),
                        child: Center(
                          child: Text('Continue', style: theme.button.copyWith(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        ));
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
    if (callbacks?.onSaveBirthday != null) {
      try {
        await callbacks!.onSaveBirthday!(dob);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authProfile);
  }
}

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Stack(
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
    );
  }
}
