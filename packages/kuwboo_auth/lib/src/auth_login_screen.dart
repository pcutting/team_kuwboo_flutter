import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart' as countries_pkg;
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Log-in counterpart to [AuthPhoneScreen]. Mirrors that screen's
/// phone/email tab layout but with copy that frames the flow as sign-in
/// and with no step-chip (login isn't a step in the sign-up sequence).
///
/// Uses the same `onSendPhoneOtp` / `onSendEmailOtp` callbacks — the
/// backend's send-OTP endpoints accept both new and existing users, so
/// one set of callbacks serves both flows. Post-OTP routing happens in
/// [AuthOtpScreen] via `onVerifyOtp`, which in the mobile app reads the
/// user's onboarding state and routes accordingly.
class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              ProtoSubBar(title: 'Log In'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _TabPill(
                        label: 'Phone',
                        active: _tabController.index == 0,
                        onTap: () => _tabController.animateTo(0),
                      ),
                      _TabPill(
                        label: 'Email',
                        active: _tabController.index == 1,
                        onTap: () => _tabController.animateTo(1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LoginPhoneTab(theme: theme),
                    _LoginEmailTab(theme: theme),
                  ],
                ),
              ),
              // Sign-up link
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 8),
                child: GestureDetector(
                  onTap: () => context.go(ProtoRoutes.authMethod),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                          text: 'Sign up',
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
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : theme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _trustedCountryCodes = {'US', 'GB', 'CA', 'AU', 'IE'};

String _initialCountryCode() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  if (locale != null && _trustedCountryCodes.contains(locale.toUpperCase())) {
    return locale.toUpperCase();
  }
  return 'US';
}

final List<countries_pkg.Country> _orderedCountries = () {
  const pinned = ['US', 'GB', 'CA', 'AU', 'IE'];
  final all = countries_pkg.countries;
  final top = [
    for (final code in pinned) all.firstWhere((c) => c.code == code),
  ];
  final rest = all.where((c) => !pinned.contains(c.code)).toList();
  return [...top, ...rest];
}();

class _LoginPhoneTab extends StatefulWidget {
  final ProtoTheme theme;
  const _LoginPhoneTab({required this.theme});

  @override
  State<_LoginPhoneTab> createState() => _LoginPhoneTabState();
}

class _LoginPhoneTabState extends State<_LoginPhoneTab> {
  PhoneNumber? _phone;
  bool _valid = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone',
            style: theme.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Semantics(
            identifier: AuthIds.phoneField,
            textField: true,
            child: IntlPhoneField(
              initialCountryCode: _initialCountryCode(),
              countries: _orderedCountries,
              disableLengthCheck: true,
              style: theme.body,
              dropdownTextStyle: theme.body,
              showCountryFlag: true,
              pickerDialogStyle: PickerDialogStyle(
                searchFieldInputDecoration: InputDecoration(
                  hintText: 'Search country',
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: theme.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.background,
                hintText: '555 123 4567',
                hintStyle: theme.body.copyWith(color: theme.textTertiary),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.text.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.text.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primary, width: 2),
                ),
              ),
              onChanged: (PhoneNumber phone) {
                setState(() {
                  _phone = phone;
                  final digits = phone.number.replaceAll(RegExp(r'\D'), '');
                  _valid = digits.length >= 7;
                });
              },
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            enabled: _valid && !_submitting,
            label: _submitting ? 'Sending code' : 'Send Code',
            liveRegion: _submitting,
            child: GestureDetector(
              onTap: (_valid && !_submitting) ? () => _submit(context) : null,
              child: Opacity(
                opacity: (_valid && !_submitting) ? 1 : 0.45,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      _submitting ? 'Sending…' : 'Send Code',
                      style: theme.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final nationalDigits = _phone!.number.replaceAll(RegExp(r'\D'), '');
    final e164 = '${_phone!.countryCode}$nationalDigits';
    final callbacks = AuthCallbacksScope.maybeOf(context);
    String? devCode;
    if (callbacks?.onSendPhoneOtp != null) {
      try {
        devCode = await callbacks!.onSendPhoneOtp!(e164);
      } catch (e, st) {
        debugLogAuthError('auth/login-phone-send', e, st);
        if (!context.mounted) return;
        setState(() => _submitting = false);
        showAuthError(context, 'Could not send code: $e');
        return;
      }
    }
    if (!context.mounted) return;
    setState(() => _submitting = false);
    context.go(
      ProtoRoutes.authOtp,
      extra: AuthOtpArgs(
        identifier: e164,
        channel: AuthOtpChannel.phone,
        displayIdentifier:
            '+${_phone!.countryCode.replaceAll('+', '')} ${_phone!.number}',
        devCode: devCode,
      ),
    );
  }
}

class _LoginEmailTab extends StatefulWidget {
  final ProtoTheme theme;
  const _LoginEmailTab({required this.theme});

  @override
  State<_LoginEmailTab> createState() => _LoginEmailTabState();
}

class _LoginEmailTabState extends State<_LoginEmailTab> {
  final TextEditingController _emailController = TextEditingController();
  bool _valid = false;
  bool _submitting = false;

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _valid = _emailRe.hasMatch(value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: theme.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Semantics(
            identifier: AuthIds.emailField,
            textField: true,
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              style: theme.body,
              onChanged: _onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.background,
                hintText: 'you@example.com',
                hintStyle: theme.body.copyWith(color: theme.textTertiary),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: theme.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.text.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.text.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primary, width: 2),
                ),
              ),
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            enabled: _valid && !_submitting,
            label: _submitting ? 'Sending code' : 'Send Code',
            liveRegion: _submitting,
            child: GestureDetector(
              onTap: (_valid && !_submitting) ? () => _submit(context) : null,
              child: Opacity(
                opacity: (_valid && !_submitting) ? 1 : 0.45,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      _submitting ? 'Sending…' : 'Send Code',
                      style: theme.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    setState(() => _submitting = true);
    final callbacks = AuthCallbacksScope.maybeOf(context);
    String? devCode;
    if (callbacks?.onSendEmailOtp != null) {
      try {
        devCode = await callbacks!.onSendEmailOtp!(email);
      } catch (e, st) {
        debugLogAuthError('auth/login-email-send', e, st);
        if (!context.mounted) return;
        setState(() => _submitting = false);
        showAuthError(context, 'Could not send code: $e');
        return;
      }
    }
    if (!context.mounted) return;
    setState(() => _submitting = false);
    context.go(
      ProtoRoutes.authOtp,
      extra: AuthOtpArgs(
        identifier: email,
        channel: AuthOtpChannel.email,
        devCode: devCode,
      ),
    );
  }
}
