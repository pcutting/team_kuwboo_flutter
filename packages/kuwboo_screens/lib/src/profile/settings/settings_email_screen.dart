import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_settings_page.dart';

class SettingsEmailScreen extends StatefulWidget {
  const SettingsEmailScreen({super.key});

  @override
  State<SettingsEmailScreen> createState() => _SettingsEmailScreenState();
}

class _SettingsEmailScreenState extends State<SettingsEmailScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    final value = _email.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!valid) {
      showSettingsSaved(context, 'Enter a valid email');
      return;
    }
    // TODO(api): POST /auth/email/change/send-link { email } and show
    // "Check your inbox" state.
    saveAndPop(context, 'Verification email sent');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return SettingsPage(
      title: 'Email',
      footer: SettingsPrimaryButton(
        label: 'Send verification email',
        onTap: _send,
      ),
      children: [
        const SettingsSectionLabel('Current email'),
        SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    theme.icons.emailOutline,
                    size: 20,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'y••••@example.com',
                    style: theme.body.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
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
        const SettingsSectionLabel('Change email'),
        SettingsTextField(
          label: 'New email address',
          controller: _email,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        Text(
          'We\'ll email a confirmation link. Your current email stays '
          'active until you click the link.',
          style: theme.caption.copyWith(color: theme.textTertiary),
        ),
      ],
    );
  }
}
