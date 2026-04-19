import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../profile_providers.dart';
import '_settings_page.dart';

class SettingsPhoneScreen extends ConsumerStatefulWidget {
  const SettingsPhoneScreen({super.key});

  @override
  ConsumerState<SettingsPhoneScreen> createState() =>
      _SettingsPhoneScreenState();
}

class _SettingsPhoneScreenState extends ConsumerState<SettingsPhoneScreen> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _send() {
    if (_phone.text.trim().length < 7) {
      showSettingsSaved(context, 'Enter a valid phone number');
      return;
    }
    // TODO(api): POST /auth/phone/change/send-otp { phone }; then navigate
    // to an OTP verify screen that accepts the new number.
    saveAndPop(context, 'Verification code sent');
  }

  /// Mask all but the last 3 digits: +447911000123 → +••••••••••123.
  String _maskPhone(String phone) {
    if (phone.length <= 3) return phone;
    return '${'•' * (phone.length - 3)}${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final meAsync = ref.watch(meProvider);
    final currentPhone = meAsync.valueOrNull?.phone;

    return SettingsPage(
      title: 'Phone Number',
      footer: SettingsPrimaryButton(
        label: 'Send verification code',
        onTap: _send,
      ),
      children: [
        const SettingsSectionLabel('Current number'),
        SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    theme.icons.phoneOutline,
                    size: 20,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentPhone == null || currentPhone.isEmpty
                        ? 'No phone on file'
                        : _maskPhone(currentPhone),
                    style: theme.body.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  if (currentPhone != null && currentPhone.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Verified',
                        style: theme.caption.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SettingsSectionLabel('Change to a new number'),
        SettingsTextField(
          label: 'New phone number',
          controller: _phone,
          hint: '+44 7xxx xxx xxx',
          keyboardType: TextInputType.phone,
        ),
        Text(
          'We\'ll text a one-time code. Your old number stays active until '
          'the new one is verified.',
          style: theme.caption.copyWith(color: theme.textTertiary),
        ),
      ],
    );
  }
}
