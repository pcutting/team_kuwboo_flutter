import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Email + password account-creation screen (PR B).
///
/// Collects email, password, confirm-password, optional name, plus the
/// two required consent checkboxes (18+ and Terms / Privacy). On submit
/// the form validates client-side, then dispatches through
/// [AuthCallbacks.onEmailRegister]. When no callbacks are supplied (web
/// prototype), the screen falls back to navigating into onboarding so
/// Neil can exercise the flow visually.
class AuthEmailRegisterScreen extends StatefulWidget {
  const AuthEmailRegisterScreen({super.key});

  @override
  State<AuthEmailRegisterScreen> createState() =>
      _AuthEmailRegisterScreenState();
}

class _AuthEmailRegisterScreenState extends State<AuthEmailRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _ageConfirmed = false;
  bool _legalAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Short client-side blocklist so obviously-weak passwords don't even
  /// reach the backend. Not exhaustive — the server has the definitive
  /// weak-password list; this is a courtesy UX check.
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    if (!_ageConfirmed || !_legalAccepted) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_passwordController.text.isEmpty) return false;
    if (_confirmPasswordController.text.isEmpty) return false;
    return true;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (v != (value ?? '')) return 'Remove trailing spaces';
    if (!_emailRe.hasMatch(v)) return 'Enter a valid email address';
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
                ProtoSubBar(title: 'Create Account'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create your account',
                                style: theme.headline.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Use your email and password. We\'ll ask you to '
                                'verify your email on the next step.',
                                style: theme.body.copyWith(
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _FieldLabel(text: 'Email', theme: theme),
                              Semantics(
                                identifier: AuthIds.registerEmailField,
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
                              _FieldLabel(text: 'Password', theme: theme),
                              Semantics(
                                identifier: AuthIds.registerPasswordField,
                                textField: true,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
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
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldLabel(
                                text: 'Confirm password',
                                theme: theme,
                              ),
                              Semantics(
                                identifier:
                                    AuthIds.registerConfirmPasswordField,
                                textField: true,
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirm,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  style: theme.body,
                                  onChanged: (_) => setState(() {}),
                                  validator: _validateConfirmPassword,
                                  decoration: _decoration(
                                    theme,
                                    hint: 'Re-enter your password',
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
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldLabel(
                                text: 'Name (optional)',
                                theme: theme,
                              ),
                              Semantics(
                                identifier: AuthIds.registerNameField,
                                textField: true,
                                child: TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  autofillHints: const [AutofillHints.name],
                                  style: theme.body,
                                  decoration: _decoration(
                                    theme,
                                    hint: 'What should we call you?',
                                    prefix: Icons.person_outline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _ConsentCheckbox(
                                identifier: AuthIds.registerAgeConfirm,
                                value: _ageConfirmed,
                                onChanged: (v) =>
                                    setState(() => _ageConfirmed = v ?? false),
                                label: Text(
                                  'I am 18 or older',
                                  style: theme.body,
                                ),
                                theme: theme,
                              ),
                              const SizedBox(height: 8),
                              _ConsentCheckbox(
                                identifier: AuthIds.registerLegalAccept,
                                value: _legalAccepted,
                                onChanged: (v) =>
                                    setState(() => _legalAccepted = v ?? false),
                                label: _legalLabel(theme),
                                theme: theme,
                              ),
                              const SizedBox(height: 24),
                              _SubmitButton(
                                identifier: AuthIds.registerSubmit,
                                label: _submitting
                                    ? 'Creating…'
                                    : 'Create Account',
                                enabled: _canSubmit,
                                busy: _submitting,
                                onTap: () => _submit(context),
                                theme: theme,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Semantics(
                                  identifier: AuthIds.registerLoginLink,
                                  button: true,
                                  label: 'Log in',
                                  child: GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      context.go(ProtoRoutes.authEmailLogin);
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Already have an account? ',
                                        children: [
                                          TextSpan(
                                            text: 'Log in',
                                            style: TextStyle(
                                              color: theme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: theme.body.copyWith(
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Leave space for the software keyboard on mobile.
                              SizedBox(
                                height: MediaQuery.viewInsetsOf(context).bottom,
                              ),
                            ],
                          ),
                        ),
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

  Widget _legalLabel(ProtoTheme theme) {
    final linkStyle = TextStyle(
      color: theme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(
        text: 'I agree to the ',
        children: [
          WidgetSpan(
            child: Semantics(
              identifier: AuthIds.registerLegalTermsLink,
              link: true,
              child: InkWell(
                onTap: () => context.push(ProtoRoutes.legalTerms),
                child: Text('Terms', style: theme.body.merge(linkStyle)),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            child: Semantics(
              identifier: AuthIds.registerLegalPrivacyLink,
              link: true,
              child: InkWell(
                onTap: () => context.push(ProtoRoutes.legalPrivacy),
                child: Text(
                  'Privacy Policy',
                  style: theme.body.merge(linkStyle),
                ),
              ),
            ),
          ),
        ],
      ),
      style: theme.body,
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

    setState(() => _submitting = true);

    final req = EmailRegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      legalAccepted: _legalAccepted,
      ageConfirmed: _ageConfirmed,
    );

    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onEmailRegister != null) {
      try {
        await callbacks!.onEmailRegister!(req);
      } catch (e, st) {
        debugLogAuthError('auth/email-register', e, st);
        if (!context.mounted) return;
        setState(() => _submitting = false);
        // Deliberately vague message: a "user exists" response could be
        // used to enumerate accounts, so never leak it in UI.
        showAuthError(
          context,
          "We couldn't create your account. "
          'Please try a different email or contact support.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    setState(() => _submitting = false);
    // On success, the host app's router redirect picks up the new
    // authenticated state and routes into onboarding. For the web
    // prototype (no callbacks), walk the user into the birthday step
    // directly so the flow is still demoable.
    if (callbacks?.onEmailRegister == null) {
      context.go(ProtoRoutes.authBirthday);
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

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.identifier,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.theme,
  });

  final String identifier;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: identifier,
      // `checked` models this as a checkbox to accessibility tooling.
      // Flutter asserts that a semantics node cannot be both `checked`
      // and `toggled` at the same time — only one is allowed per node.
      checked: value,
      button: true,
      container: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use a simple box so the whole row is the tap target and the
            // Semantics identifier points at the row — otherwise Flutter's
            // default Checkbox hosts its own semantics node and the
            // identifier ends up on the wrapper but the tap only lands on
            // the checkbox itself, which Maestro struggles with.
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value
                        ? theme.primary
                        : theme.text.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            Expanded(child: label),
          ],
        ),
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
      label: busy ? 'Creating account' : label,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
