import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import '_step_chip.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

const int _otpLength = 6;

class AuthOtpScreen extends StatefulWidget {
  const AuthOtpScreen({super.key, this.args});

  /// Identifier (phone or email) and channel the code was sent on.
  /// When null (mock prototype), screen shows a placeholder identifier
  /// and advances to the birthday screen on auto-submit.
  final AuthOtpArgs? args;

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  bool _canResend = false;
  int _countdown = 30;

  /// True while a verify call is in flight. Guarding both auto-submit and
  /// the post-verify navigation on this flag prevents (a) paste + resend
  /// firing overlapping verifies, and (b) a stale verify result
  /// navigating after the user resent the code.
  bool _isVerifying = false;

  /// Snapshot of the args captured when the route first mounts. Read this
  /// instead of [AuthOtpScreen.args] — go_router's `refreshListenable`
  /// rebuilds the match with `state.extra = null` on any auth-state
  /// notification (e.g. the `isLoading` toggle during verify), which would
  /// otherwise flip the screen to its fallback identifier mid-verify.
  AuthOtpArgs? _args;

  @override
  void initState() {
    super.initState();
    _args = widget.args;
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant AuthOtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args != null && widget.args != oldWidget.args) {
      _args = widget.args;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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

  void _onChanged(int index, String value) {
    // Handle paste: if value contains multiple digits, fan out across boxes.
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (var i = 0; i < _otpLength; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        } else {
          _controllers[i].clear();
        }
      }
      final nextFocus = digits.length >= _otpLength
          ? _otpLength - 1
          : digits.length;
      FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
      _maybeAutoSubmit();
      return;
    }

    if (digits.isEmpty) {
      // User cleared this box — leave focus here.
      setState(() {});
      return;
    }

    // Single digit entered.
    _controllers[index].text = digits;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _controllers[index].text.length),
    );

    // Trigger a rebuild so the `_OtpBox` Semantics widget re-reads each
    // controller's text into its `value:` parameter. Without this the
    // outer Semantics annotation stays at the initial empty string and
    // assistive tech / Maestro can't read what's actually in the box.
    setState(() {});

    if (index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    _maybeAutoSubmit();
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      // Auto-back on delete when current box is empty.
      _controllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _maybeAutoSubmit() {
    final full = _controllers.map((c) => c.text).join();
    if (full.length == _otpLength && !_isVerifying) {
      unawaited(_submit(full));
    }
  }

  Future<void> _submit(String code) async {
    _isVerifying = true;
    final callbacks = AuthCallbacksScope.maybeOf(context);
    final args = _args;
    try {
      if (callbacks?.onVerifyOtp != null && args != null) {
        try {
          await callbacks!.onVerifyOtp!(args.identifier, code, args.channel);
          if (!mounted) return;
          // If _resend() fired while we were awaiting, it cleared
          // _isVerifying and we must NOT navigate — the user is about to
          // enter a fresh code.
          if (!_isVerifying) return;
          // Auth state has flipped to authenticated. The router's redirect
          // keeps new users inside /auth/* but won't choose a step for us —
          // explicitly advance to the next onboarding screen.
          context.go(ProtoRoutes.authBirthday);
        } catch (e, st) {
          debugLogAuthError('auth/otp-verify', e, st);
          if (!mounted) return;
          if (!_isVerifying) return; // cancelled by a concurrent resend
          setState(() {
            for (final c in _controllers) {
              c.clear();
            }
          });
          FocusScope.of(context).requestFocus(_focusNodes[0]);
          showAuthError(context, 'Invalid code: $e');
        }
        return;
      }
      // Mock prototype flow — advance after a brief delay.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      if (!_isVerifying) return;
      context.go(ProtoRoutes.authBirthday);
    } finally {
      if (mounted) {
        _isVerifying = false;
      }
    }
  }

  Future<void> _resend() async {
    // Cancel any in-flight verify by flipping the flag; _submit() checks
    // this before navigating so a stale success can't jump the user past
    // the fresh code entry.
    _isVerifying = false;
    setState(() {
      _canResend = false;
      _countdown = 30;
      for (final c in _controllers) {
        c.clear();
      }
    });
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    _startCountdown();
    final callbacks = AuthCallbacksScope.maybeOf(context);
    final args = _args;
    if (callbacks?.onResendOtp != null && args != null) {
      try {
        await callbacks!.onResendOtp!(args.identifier, args.channel);
      } catch (e, st) {
        debugLogAuthError('auth/otp-resend', e, st);
        if (!mounted) return;
        showAuthError(context, 'Could not resend: $e');
      }
    }
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
              ProtoSubBar(title: 'Verification'),
              const StepChip(step: 3),
              // Only surface the banner when we actually have a code to show
              // (dev / demo mode). In production the backend omits `devCode`
              // from the response so this renders nothing.
              if (!kReleaseMode && _args?.devCode != null)
                Semantics(
                  identifier: AuthIds.otpBanner,
                  child: _TestBuildBanner(devCode: _args!.devCode!),
                )
              else
                const SizedBox.shrink(),
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
                      Semantics(
                        identifier: AuthIds.otpIdentifier,
                        child: Text(
                          _args?.displayIdentifier ??
                              _args?.identifier ??
                              'your account',
                          style: theme.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Six OTP digit boxes — Expanded so they share the
                      // available row width instead of using a fixed 48px
                      // that overflows inside the 390-px PhoneFrame.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_otpLength, (i) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _OtpBox(
                                identifier: AuthIds.otpDigit(i),
                                index: i,
                                value: _controllers[i].text,
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                onChanged: (v) => _onChanged(i, v),
                                onKey: (event) => _onKey(i, event),
                                theme: theme,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),

                      if (!_canResend)
                        Text(
                          'Resend code in 0:${_countdown.toString().padLeft(2, '0')}',
                          style: theme.caption.copyWith(
                            color: theme.textTertiary,
                          ),
                        )
                      else
                        Semantics(
                          identifier: AuthIds.otpResend,
                          button: true,
                          label: 'Resend code',
                          enabled: _canResend,
                          child: GestureDetector(
                            onTap: _resend,
                            child: Text(
                              "Didn't get a code? Resend",
                              style: theme.caption.copyWith(
                                color: theme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const Spacer(),
                      const SizedBox(height: 20),
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
}

class _OtpBox extends StatelessWidget {
  final String identifier;
  final int index;
  final String value;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent) onKey;
  final ProtoTheme theme;

  const _OtpBox({
    required this.identifier,
    required this.index,
    required this.value,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    final active = focusNode.hasFocus;
    // Width is driven by the parent Expanded; height stays fixed so the
    // boxes feel rectangular rather than collapsing to a square.
    return SizedBox(
      height: 64,
      child: Semantics(
        identifier: identifier,
        label: 'OTP digit ${index + 1} of $_otpLength',
        textField: true,
        value: value,
        child: Focus(
          onKeyEvent: (_, event) => onKey(event),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: theme.headline.copyWith(fontSize: 26),
            cursorColor: theme.primary,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: theme.background,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: filled
                      ? theme.primary.withValues(alpha: 0.3)
                      : theme.text.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: active ? theme.primary : theme.text,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: const [],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _TestBuildBanner extends StatelessWidget {
  const _TestBuildBanner({required this.devCode});

  /// Plaintext 6-digit code the backend returned on `send-otp` in local-dev
  /// mode. Rendered bold in the banner so the user can type it verbatim.
  final String devCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade900),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'TEST BUILD — your code is '),
                  TextSpan(
                    text: devCode,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
