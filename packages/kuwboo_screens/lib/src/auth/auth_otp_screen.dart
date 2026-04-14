import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthOtpScreen extends StatefulWidget {
  const AuthOtpScreen({super.key});

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  final List<int?> _digits = [null, null, null, null];
  int _activeIndex = 0;
  bool _canResend = false;
  int _countdown = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
        if (_countdown <= 0) _canResend = true;
      });
      return _countdown > 0;
    });
  }

  void _onDigitTap(int digit) {
    if (_activeIndex >= 4) return;
    setState(() {
      _digits[_activeIndex] = digit;
      _activeIndex++;
    });
    if (_activeIndex == 4) {
      // Auto-advance after short delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          PrototypeStateProvider.of(context).push(ProtoRoutes.authBirthday);
        }
      });
    }
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
          ProtoSubBar(title: 'Verification'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Enter the code we sent to',
                    style: theme.headline.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+44 7XXX XXX XX3',
                    style: theme.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP digit boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = _digits[i] != null;
                      final active = i == _activeIndex;
                      return Container(
                        width: 56,
                        height: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? theme.primary
                                : filled
                                    ? theme.primary.withValues(alpha: 0.3)
                                    : theme.text.withValues(alpha: 0.08),
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filled ? '${_digits[i]}' : '',
                            style: theme.headline.copyWith(fontSize: 28),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Resend
                  if (!_canResend)
                    Text(
                      'Resend code in 0:${_countdown.toString().padLeft(2, '0')}',
                      style: theme.caption.copyWith(color: theme.textTertiary),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _canResend = false;
                          _countdown = 30;
                          _activeIndex = 0;
                          _digits.fillRange(0, 4, null);
                        });
                        _startCountdown();
                      },
                      child: Text(
                        "Didn't get a code? Resend",
                        style: theme.caption.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Mock numeric keypad
                  _NumPad(onDigit: _onDigitTap),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
        ));
  }
}

class _NumPad extends StatelessWidget {
  final void Function(int digit) onDigit;
  const _NumPad({required this.onDigit});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    Widget key(String label, {VoidCallback? onTap}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: label.isNotEmpty ? theme.background : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: theme.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            children: row.map((d) => key('$d', onTap: () => onDigit(d))).toList(),
          ),
        Row(
          children: [
            key(''),
            key('0', onTap: () => onDigit(0)),
            key(''),
          ],
        ),
      ],
    );
  }
}
