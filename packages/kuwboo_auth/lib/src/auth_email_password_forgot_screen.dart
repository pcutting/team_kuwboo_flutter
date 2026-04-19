import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Password-reset request screen (PR C).
///
/// Entry point for the "Forgot password?" affordance on
/// [AuthEmailLoginScreen]. Captures an email address and hands it to
/// [AuthCallbacks.onEmailPasswordForgot], then advances to a neutral
/// success state regardless of whether the email is actually on file —
/// this matches the backend's deliberately-vague 2xx response and
/// avoids account-existence leakage.
class AuthEmailPasswordForgotScreen extends StatefulWidget {
  const AuthEmailPasswordForgotScreen({super.key});

  @override
  State<AuthEmailPasswordForgotScreen> createState() =>
      _AuthEmailPasswordForgotScreenState();
}

class _AuthEmailPasswordForgotScreenState
    extends State<AuthEmailPasswordForgotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String _sentEmail = '';

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    final v = _emailController.text.trim();
    if (v.isEmpty) return false;
    if (!_emailRe.hasMatch(v)) return false;
    return true;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (v != (value ?? '')) return 'Remove trailing spaces';
    if (!_emailRe.hasMatch(v)) return 'Enter a valid email address';
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
                  child: _sent
                      ? _buildSuccess(theme)
                      : _buildForm(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ProtoTheme theme) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(
              'Forgot your password?',
              style: theme.headline.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the email on your account. We\'ll send you a code '
              'to reset your password.',
              style: theme.body.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 20),
            _FieldLabel(text: 'Email', theme: theme),
            Semantics(
              identifier: AuthIds.forgotEmailField,
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
            const SizedBox(height: 24),
            _SubmitButton(
              identifier: AuthIds.forgotSubmit,
              label: _submitting ? 'Sending…' : 'Send reset code',
              enabled: _canSubmit,
              busy: _submitting,
              onTap: () => _submit(context),
              theme: theme,
            ),
            const SizedBox(height: 16),
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
                  style: theme.body.copyWith(color: theme.textSecondary),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const SizedBox(height: 12),
        Icon(Icons.mark_email_read_outlined, size: 48, color: theme.primary),
        const SizedBox(height: 16),
        Text(
          'Check your inbox',
          style: theme.headline.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'If an account exists for $_sentEmail, we sent a reset code. '
          'Check your inbox and click the button below to enter it.',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 24),
        _SubmitButton(
          identifier: AuthIds.forgotSuccessAdvance,
          label: 'I have the code',
          enabled: true,
          busy: false,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            final uri = Uri(
              path: ProtoRoutes.authEmailPasswordReset,
              queryParameters: {'email': _sentEmail},
            );
            context.go(uri.toString());
          },
          theme: theme,
        ),
        const SizedBox(height: 16),
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
              style: theme.body.copyWith(color: theme.textSecondary),
            ),
          ),
        ),
      ],
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
    setState(() => _submitting = true);

    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onEmailPasswordForgot != null) {
      try {
        await callbacks!.onEmailPasswordForgot!(email);
      } catch (e, st) {
        debugLogAuthError('auth/email-password-forgot', e, st);
        if (!context.mounted) return;
        setState(() => _submitting = false);
        // Network / rate-limit failure. Don't leak account existence —
        // just tell the user the request couldn't go through.
        showAuthError(
          context,
          "We couldn't send a reset code. "
          'Please try again in a moment.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    setState(() {
      _submitting = false;
      _sent = true;
      _sentEmail = email;
    });
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
      label: busy ? 'Sending reset code' : label,
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
