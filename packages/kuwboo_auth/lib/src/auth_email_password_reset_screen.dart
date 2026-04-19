import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Password-reset completion screen (PR C).
///
/// Landed from [AuthEmailPasswordForgotScreen]'s success state. Collects
/// the email (pre-filled via the `email` query param), the code the
/// user received via email, and a new password. On submit, dispatches
/// through [AuthCallbacks.onEmailPasswordReset]. A successful callback
/// results in the host issuing tokens + updating auth state — the
/// router redirect then advances the user. An invalid-code failure
/// surfaces as an inline error on the code field, matching the server's
/// 400 response. Account-existence leakage is avoided: the UI never
/// says "we don't know that email".
class AuthEmailPasswordResetScreen extends StatefulWidget {
  const AuthEmailPasswordResetScreen({super.key, this.initialEmail});

  /// Pre-fills the email field. Comes from the `email` query param on
  /// the route — the forgot screen pushes this through so the user
  /// doesn't have to re-type their address.
  final String? initialEmail;

  @override
  State<AuthEmailPasswordResetScreen> createState() =>
      _AuthEmailPasswordResetScreenState();
}

class _AuthEmailPasswordResetScreenState
    extends State<AuthEmailPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _codeError;

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Same short courtesy blocklist as the register screen. The server
  /// has the definitive list; this keeps UX snappy for the obvious
  /// cases.
  static const _weakPasswords = <String>{
    'password',
    'password1',
    '12345678',
    'qwerty12',
    'letmein1',
    'welcome1',
    'iloveyou',
    'admin123',
    'abc12345',
    'password123',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    if (_codeError != null) return false;
    if (_validateEmail(_emailController.text) != null) return false;
    if (_validateCode(_codeController.text) != null) return false;
    if (_validatePassword(_passwordController.text) != null) return false;
    if (_validateConfirmPassword(_confirmPasswordController.text) != null) {
      return false;
    }
    return true;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (v != (value ?? '')) return 'Remove trailing spaces';
    if (!_emailRe.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validateCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter the code we sent you';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Numbers only';
    if (v.length < 4) return 'Code is too short';
    if (v.length > 12) return 'Code is too long';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (_weakPasswords.contains(v.toLowerCase())) {
      return 'Pick a stronger password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
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
          child: SafeArea(
            child: Column(
              children: [
                ProtoSubBar(title: 'Reset password'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        children: [
                          Text(
                            'Set a new password',
                            style: theme.headline.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter the code we emailed you and choose a new '
                            'password.',
                            style: theme.body
                                .copyWith(color: theme.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          _FieldLabel(text: 'Email', theme: theme),
                          Semantics(
                            identifier: AuthIds.resetEmailField,
                            textField: true,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              autofillHints: const [AutofillHints.email],
                              style: theme.body,
                              onChanged: (_) => setState(() {}),
                              validator: _validateEmail,
                              decoration: _decoration(
                                theme,
                                hint: 'you@example.com',
                                prefix: Icons.email_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FieldLabel(text: 'Code', theme: theme),
                          Semantics(
                            identifier: AuthIds.resetCodeField,
                            textField: true,
                            child: TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: theme.body,
                              onChanged: (_) {
                                if (_codeError != null) {
                                  setState(() => _codeError = null);
                                } else {
                                  setState(() {});
                                }
                              },
                              validator: (v) =>
                                  _codeError ?? _validateCode(v),
                              decoration: _decoration(
                                theme,
                                hint: '1234',
                                prefix: Icons.pin_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FieldLabel(text: 'New password', theme: theme),
                          Semantics(
                            identifier: AuthIds.resetPasswordField,
                            textField: true,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              style: theme.body,
                              onChanged: (_) => setState(() {}),
                              validator: _validatePassword,
                              decoration: _decoration(
                                theme,
                                hint: 'At least 8 characters',
                                prefix: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: theme.textTertiary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FieldLabel(
                            text: 'Confirm new password',
                            theme: theme,
                          ),
                          Semantics(
                            identifier: AuthIds.resetConfirmPasswordField,
                            textField: true,
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              autofillHints: const [AutofillHints.newPassword],
                              style: theme.body,
                              onChanged: (_) => setState(() {}),
                              validator: _validateConfirmPassword,
                              decoration: _decoration(
                                theme,
                                hint: 'Re-enter your new password',
                                prefix: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: theme.textTertiary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SubmitButton(
                            identifier: AuthIds.resetSubmit,
                            label:
                                _submitting ? 'Resetting…' : 'Reset password',
                            enabled: _canSubmit,
                            busy: _submitting,
                            onTap: () => _submit(context),
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Semantics(
                              identifier: AuthIds.resetResendLink,
                              button: true,
                              label: 'Resend code',
                              child: GestureDetector(
                                onTap: _submitting
                                    ? null
                                    : () => _resend(context),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Didn't get a code? ",
                                    children: [
                                      TextSpan(
                                        text: 'Resend',
                                        style: TextStyle(
                                          color: theme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: theme.body
                                      .copyWith(color: theme.textSecondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                context.go(ProtoRoutes.authEmailLogin);
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: 'Remembered it? ',
                                  children: [
                                    TextSpan(
                                      text: 'Back to log in',
                                      style: TextStyle(
                                        color: theme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                style: theme.body
                                    .copyWith(color: theme.textSecondary),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.viewInsetsOf(context).bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    ProtoTheme theme, {
    required String hint,
    IconData? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: theme.background,
      hintText: hint,
      hintStyle: theme.body.copyWith(color: theme.textTertiary),
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, size: 20, color: theme.textTertiary),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.text.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.text.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primary, width: 2),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _passwordController.text;

    setState(() {
      _submitting = true;
      _codeError = null;
    });

    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onEmailPasswordReset != null) {
      try {
        await callbacks!.onEmailPasswordReset!(email, code, newPassword);
      } catch (e, st) {
        debugLogAuthError('auth/email-password-reset', e, st);
        if (!context.mounted) return;
        // Invalid / expired code is the most common failure. Surface it
        // inline on the code field — and never leak whether the email
        // was on file. For other shapes, show a vague SnackBar so the
        // user has a clear "try again" affordance.
        if (_looksLikeInvalidCode(e)) {
          setState(() {
            _submitting = false;
            _codeError = 'Invalid or expired code';
          });
          _formKey.currentState?.validate();
          return;
        }
        setState(() => _submitting = false);
        showAuthError(
          context,
          "We couldn't reset your password. "
          'Please try again or contact support.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    setState(() => _submitting = false);
    // On success with a live callback, the host has issued tokens and
    // the router redirect will carry the user forward — nothing to do
    // here. For the web prototype (no callbacks), walk the user to the
    // login screen so the demo flow terminates sensibly.
    if (callbacks?.onEmailPasswordReset == null) {
      context.go(ProtoRoutes.authEmailLogin);
    }
  }

  Future<void> _resend(BuildContext context) async {
    final email = _emailController.text.trim();
    if (_validateEmail(email) != null) {
      showAuthError(context, 'Enter the email on your account first.');
      return;
    }
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onEmailPasswordForgot != null) {
      try {
        await callbacks!.onEmailPasswordForgot!(email);
      } catch (e, st) {
        debugLogAuthError('auth/email-password-forgot', e, st);
        if (!context.mounted) return;
        showAuthError(
          context,
          "We couldn't resend the code. Please try again in a moment.",
        );
        return;
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Code re-sent.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Best-effort check for "invalid / expired code" errors so we can
  /// surface the inline message. We deliberately stay tolerant: the
  /// notifier layer wraps DioException into a plain [String] message,
  /// and the backend's phrasing may drift.
  bool _looksLikeInvalidCode(Object e) {
    final lower = e.toString().toLowerCase();
    return lower.contains('code') &&
        (lower.contains('invalid') ||
            lower.contains('expired') ||
            lower.contains('incorrect'));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.theme});
  final String text;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.identifier,
    required this.label,
    required this.enabled,
    required this.busy,
    required this.onTap,
    required this.theme,
  });

  final String identifier;
  final String label;
  final bool enabled;
  final bool busy;
  final VoidCallback onTap;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: identifier,
      container: true,
      button: true,
      enabled: enabled,
      liveRegion: busy,
      label: busy ? 'Resetting password' : label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusFull),
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(label, style: theme.button.copyWith(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
