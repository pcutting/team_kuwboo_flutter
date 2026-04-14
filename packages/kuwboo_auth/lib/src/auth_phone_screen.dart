import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

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
    final state = PrototypeStateProvider.of(context);

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
                  _PhoneTab(state: state, theme: theme),
                  _EmailTab(state: state, theme: theme),
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
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _PhoneTab({required this.state, required this.theme});

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
              onTap: _valid
                  ? () {
                      // Full E.164 phone: widget.state could persist `_phone!.completeNumber`
                      // once a user/session store exists. Prototype just advances.
                      final _ = _phone!.completeNumber;
                      widget.state.push(ProtoRoutes.authOtp);
                    }
                  : null,
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
}

class _EmailTab extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _EmailTab({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 20, color: theme.textTertiary),
                const SizedBox(width: 12),
                Text(
                  'you@example.com',
                  style: theme.body.copyWith(color: theme.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Password',
            style: theme.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: theme.textTertiary),
                const SizedBox(width: 12),
                Text(
                  'Create a password',
                  style: theme.body.copyWith(color: theme.textTertiary),
                ),
                const Spacer(),
                Icon(Icons.visibility_off_outlined,
                    size: 20, color: theme.textTertiary),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: () => state.push(ProtoRoutes.authBirthday),
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
        ],
      ),
    );
  }
}
