import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../providers/auth_provider.dart';

/// Phone number input screen. Sends an OTP to the entered number.
///
/// Uses `phone_form_field` so the dial code auto-defaults to the device's
/// locale country and the user can tap the flag to pick any other country
/// instead of typing raw E.164.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final PhoneController _phoneController;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController = PhoneController(
      initialValue: PhoneNumber(isoCode: _initialIsoCode(), nsn: ''),
    );
  }

  /// Best-guess country from the device's locale. Falls back to US if the
  /// locale has no country component (common on fresh emulators) or if the
  /// code isn't one libphonenumber recognizes.
  static IsoCode _initialIsoCode() {
    final country = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode
            ?.toUpperCase() ??
        'US';
    for (final iso in IsoCode.values) {
      if (iso.name == country) return iso;
    }
    return IsoCode.US;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final number = _phoneController.value;
    if (number.nsn.isEmpty) {
      setState(() => _error = 'Enter your phone number');
      return;
    }
    if (!number.isValid()) {
      setState(() => _error = 'That phone number looks invalid');
      return;
    }

    final e164 = number.international; // e.g. "+447700900000"

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).requestOtp(e164);
      if (!mounted) return;
      context.go('/otp', extra: e164);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/kuwboo-logo.png',
                height: 48,
                errorBuilder: (_, _, _) => const SizedBox(height: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Kuwboo',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to get started',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PhoneFormField(
                controller: _phoneController,
                autofillHints: const [AutofillHints.telephoneNumber],
                countryButtonStyle: const CountryButtonStyle(
                  showFlag: true,
                  showDialCode: true,
                  showDropdownIcon: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSending ? null : _sendOtp,
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
