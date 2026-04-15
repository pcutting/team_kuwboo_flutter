import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

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

class _PhoneTabState extends State<_PhoneTab> {
  PhoneNumber? _phone;
  bool _valid = false;
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
          // TODO(D2): derive initialCountryCode from device locale.
          IntlPhoneField(
            initialCountryCode: 'US',
            disableLengthCheck: false,
            style: theme.body,
            dropdownTextStyle: theme.body,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _valid ? () => _submit(context) : null,
              child: Opacity(
                opacity: _valid ? 1 : 0.45,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      'Send Code',
                      style: theme.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final e164 = _phone!.completeNumber;
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSendPhoneOtp != null) {
      try {
        await callbacks!.onSendPhoneOtp!(e164);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send code: $e')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    context.go(
      ProtoRoutes.authOtp,
      extra: AuthOtpArgs(identifier: e164, channel: AuthOtpChannel.phone),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _valid ? () => _submit(context) : null,
              child: Opacity(
                opacity: _valid ? 1 : 0.45,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: theme.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final email = _emailController.text.trim();
    if (!_emailRe.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSendEmailOtp != null) {
      try {
        await callbacks!.onSendEmailOtp!(email);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send code: $e')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    context.go(
      ProtoRoutes.authOtp,
      extra: AuthOtpArgs(identifier: email, channel: AuthOtpChannel.email),
    );
  }
}
