import 'package:flutter/material.dart';

import '_settings_page.dart';

class SettingsPasswordScreen extends StatefulWidget {
  const SettingsPasswordScreen({super.key});

  @override
  State<SettingsPasswordScreen> createState() => _SettingsPasswordScreenState();
}

class _SettingsPasswordScreenState extends State<SettingsPasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _valid =>
      _current.text.isNotEmpty &&
      _next.text.length >= 8 &&
      _next.text == _confirm.text;

  void _submit() {
    if (!_valid) {
      showSettingsSaved(context, 'Passwords must match and be 8+ characters');
      return;
    }
    // TODO(api): POST /auth/password/change { currentPassword, newPassword }
    saveAndPop(context, 'Password updated');
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Password',
      footer: SettingsPrimaryButton(label: 'Update password', onTap: _submit),
      children: [
        SettingsTextField(
          label: 'Current password',
          controller: _current,
          obscureText: true,
        ),
        SettingsTextField(
          label: 'New password',
          controller: _next,
          obscureText: true,
          hint: 'At least 8 characters',
        ),
        SettingsTextField(
          label: 'Confirm new password',
          controller: _confirm,
          obscureText: true,
        ),
      ],
    );
  }
}
