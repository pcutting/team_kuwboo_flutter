import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Email + password sign-in screen (PR B).
///
/// Paired with [AuthEmailRegisterScreen]. The form intentionally does
/// no more than shape validation on the password — the server owns the
/// definitive verdict. On submit, dispatches through
/// [AuthCallbacks.onEmailLogin]; with no callbacks supplied, falls back
/// to mock navigation so the web prototype still flows.
class AuthEmailLoginScreen extends StatefulWidget {
  const AuthEmailLoginScreen({super.key});

  @override
  State<AuthEmailLoginScreen> createState() => _AuthEmailLoginScreenState();
}

class _AuthEmailLoginScreenState extends State<AuthEmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_passwordController.text.isEmpty) return false;
    return true;
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
                ProtoSubBar(title: 'Log In'),
                Expanded(
                  child: AutofillGroup(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.headline.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Log in with your email and password.',
                          style:
                              theme.body.copyWith(color: theme.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel(text: 'Email', theme: theme),
                        Semantics(
                          identifier: AuthIds.loginEmailField,
                          textField: true,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.none,
                            autofillHints: const [AutofillHints.email],
                            style: theme.body,
                            onChanged: (_) => setState(() {}),
                            decoration: _decoration(
                              theme,
                              hint: 'you@example.com',
                              prefix: Icons.email_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel(text: 'Password', theme: theme),
                        Semantics(
                          identifier: AuthIds.loginPasswordField,
                          textField: true,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            style: theme.body,
                            onChanged: (_) => setState(() {}),
                            decoration: _decoration(
                              theme,
                              hint: 'Your password',
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
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Semantics(
                            identifier: AuthIds.loginForgotPassword,
                            button: true,
                            label: 'Forgot password?',
                            child: GestureDetector(
                              onTap: () => context
                                  .go(ProtoRoutes.authEmailPasswordForgot),
                              child: Text(
                                'Forgot password?',
                                style: theme.body.copyWith(
                                  color: theme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SubmitButton(
                          identifier: AuthIds.loginSubmit,
                          label: _submitting ? 'Logging in…' : 'Log in',
                          enabled: _canSubmit,
                          busy: _submitting,
                          onTap: () => _submit(context),
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Semantics(
                            identifier: AuthIds.loginRegisterLink,
                            button: true,
                            label: 'Create account',
                            child: GestureDetector(
                              onTap: () =>
                                  context.go(ProtoRoutes.authEmailRegister),
                              child: Text.rich(
                                TextSpan(
                                  text: 'New to Kuwboo? ',
                                  children: [
                                    TextSpan(
                                      text: 'Create account',
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
                        SizedBox(
                          height: MediaQuery.viewInsetsOf(context).bottom,
                        ),
                      ],
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

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() => _submitting = true);

    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onEmailLogin != null) {
      try {
        await callbacks!.onEmailLogin!(email, password);
      } catch (e, st) {
        debugLogAuthError('auth/email-login', e, st);
        if (!context.mounted) return;
        setState(() => _submitting = false);
        showAuthError(
          context,
          'Invalid email or password. Please try again.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    setState(() => _submitting = false);
    // On success, the host app's router redirect picks up the new
    // authenticated state and routes into the main shell. For the web
    // prototype (no callbacks), jump to the main feed so the flow
    // demos end-to-end.
    if (callbacks?.onEmailLogin == null) {
      context.go(ProtoRoutes.videoFeed);
    }
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
      label: busy ? 'Logging in' : label,
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
