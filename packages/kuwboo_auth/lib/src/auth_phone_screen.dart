import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart' as countries_pkg;
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as pnp;

import 'auth_callbacks.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen>
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

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.surface,
        child: Column(
          children: [
            ProtoSubBar(title: 'Sign Up'),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
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
            const SizedBox(height: 24),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PhoneTab(theme: theme),
                  _EmailTab(theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill(
      {required this.label, required this.active, required this.onTap});

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

class _PhoneTab extends StatefulWidget {
  final ProtoTheme theme;
  const _PhoneTab({required this.theme});

  @override
  State<_PhoneTab> createState() => _PhoneTabState();
}

// Pin the common English-speaking markets at the top of the country picker,
// then the rest in the package's original (alphabetical) order.
final List<countries_pkg.Country> _orderedCountries = () {
  const pinned = ['US', 'GB', 'CA', 'AU', 'IE'];
  final all = countries_pkg.countries;
  final top = [
    for (final code in pinned)
      all.firstWhere((c) => c.code == code),
  ];
  final rest = all.where((c) => !pinned.contains(c.code)).toList();
  return [...top, ...rest];
}();

class _PhoneTabState extends State<_PhoneTab> {
  PhoneNumber? _phone;
  bool _valid = false;
  bool _submitting = false;
  // Full E.164 phone passed forward once validation completes.
  // ignore: unused_field
  String _e164 = '';

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
          IntlPhoneField(
            initialCountryCode: WidgetsBinding
                    .instance.platformDispatcher.locale.countryCode ??
                'GB',
            countries: _orderedCountries,
            disableLengthCheck: false,
            style: theme.body,
            dropdownTextStyle: theme.body,
            showCountryFlag: true,
            inputFormatters: [
              _PhoneNumberFormatter(country: _phone?.countryCode ?? '1'),
            ],
            pickerDialogStyle: PickerDialogStyle(
              searchFieldInputDecoration: InputDecoration(
                hintText: 'Search country',
                prefixIcon:
                    Icon(Icons.search, size: 18, color: theme.textTertiary),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
            onChanged: (PhoneNumber phone) {
              setState(() {
                _phone = phone;
                // IntlPhoneField validates length per country and surfaces
                // errors via its own validator; we treat a present completeNumber
                // of sufficient length as valid for prototype purposes.
                final digits = phone.number.replaceAll(RegExp(r'\D'), '');
                _valid = digits.length >= 7;
                _e164 = _valid ? phone.completeNumber : '';
              });
            },
          ),
          const Spacer(),
          _BottomAction(
            label: _submitting ? 'Sending…' : 'Send Code',
            enabled: _valid && !_submitting,
            onTap: () => _submit(context),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final e164 = _phone!.completeNumber;
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSendPhoneOtp != null) {
      try {
        await callbacks!.onSendPhoneOtp!(e164);
      } catch (e) {
        if (!context.mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send code: $e')),
        );
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
        // Human-readable form for the OTP confirmation screen. Keep the
        // raw E.164 as the canonical identifier for the verify call.
        displayIdentifier:
            '+${_phone!.countryCode.replaceAll('+', '')} ${_phone!.number}',
      ),
    );
  }
}

class _EmailTab extends StatefulWidget {
  final ProtoTheme theme;
  const _EmailTab({required this.theme});

  @override
  State<_EmailTab> createState() => _EmailTabState();
}

class _EmailTabState extends State<_EmailTab> {
  final TextEditingController _emailController = TextEditingController();
  String? _error;
  bool _valid = false;
  bool _submitting = false;

  // Pragmatic email regex — same shape backend's class-validator uses.
  static final RegExp _emailRe =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _valid = _emailRe.hasMatch(value.trim());
      _error = null;
    });
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
          TextField(
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
              prefixIcon:
                  Icon(Icons.email_outlined, size: 20, color: theme.textTertiary),
              errorText: _error,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
          const Spacer(),
          _BottomAction(
            label: _submitting ? 'Sending…' : 'Next',
            enabled: _valid && !_submitting,
            onTap: () => _submit(context),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (!_emailRe.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() => _submitting = true);
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSendEmailOtp != null) {
      try {
        await callbacks!.onSendEmailOtp!(email);
      } catch (e) {
        if (!context.mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send code: $e')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    setState(() => _submitting = false);
    context.go(
      ProtoRoutes.authOtp,
      extra: AuthOtpArgs(identifier: email, channel: AuthOtpChannel.email),
    );
  }
}

/// Bottom CTA that rides above the keyboard. Uses MediaQuery.viewInsetsOf
/// so the button stays visible as the on-screen keyboard opens/closes.
class _BottomAction extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final ProtoTheme theme;
  const _BottomAction({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    // When the keyboard is up, lift the button just above it with a small
    // visual gap. Otherwise sit above the home indicator with a resting
    // margin so it's not crammed against the bottom bezel.
    final lift = keyboard > 0 ? keyboard + 8 : safeBottom + 24;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: lift),
      child: Semantics(
        label: label,
        button: true,
        enabled: enabled,
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
              child: Text(
                label,
                style: theme.button.copyWith(fontSize: 16),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Live-formats the user's input per the selected country's national format
/// using `phone_numbers_parser`. Falls back to the raw digits on parse
/// failure (partial entry, unsupported country, etc.) so the field never
/// eats keystrokes.
class _PhoneNumberFormatter extends TextInputFormatter {
  _PhoneNumberFormatter({required this.country});

  /// Current country calling code (no leading `+`), e.g. `'1'` for US, `'44'`
  /// for GB. Supplied by the enclosing widget from `IntlPhoneField`'s
  /// currently-selected country.
  final String country;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    try {
      final parsed = pnp.PhoneNumber.parse('+$country$digits');
      final formatted = parsed.formatNsn();
      if (formatted.isEmpty) return newValue;
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (_) {
      return newValue;
    }
  }
}
