import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../profile_providers.dart';
import '_settings_page.dart';

class SettingsEmailScreen extends ConsumerStatefulWidget {
  const SettingsEmailScreen({super.key});

  @override
  ConsumerState<SettingsEmailScreen> createState() =>
      _SettingsEmailScreenState();
}

class _SettingsEmailScreenState extends ConsumerState<SettingsEmailScreen> {
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

  /// Mask the local part so "foo@bar.com" → "f••@bar.com".
  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final local = email.substring(0, at);
    final domain = email.substring(at);
    final keep = local[0];
    final masked = '•' * (local.length - 1).clamp(1, 8);
    return '$keep$masked$domain';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final meAsync = ref.watch(meProvider);
    final currentEmail = meAsync.valueOrNull?.email;

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
                  Expanded(
                    child: Text(
                      currentEmail == null || currentEmail.isEmpty
                          ? 'No email on file'
                          : _maskEmail(currentEmail),
                      style: theme.body.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (currentEmail != null && currentEmail.isNotEmpty)
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
                        'On file',
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
