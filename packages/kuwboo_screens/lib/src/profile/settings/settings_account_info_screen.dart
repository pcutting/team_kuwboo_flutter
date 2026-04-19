import 'package:flutter/material.dart';

import '_settings_page.dart';

/// Edit display name, username, bio. Birthday shown read-only (edit flows
/// through the auth birthday step because DOB is age-gated).
class SettingsAccountInfoScreen extends StatefulWidget {
  const SettingsAccountInfoScreen({super.key});

  @override
  State<SettingsAccountInfoScreen> createState() =>
      _SettingsAccountInfoScreenState();
}

class _SettingsAccountInfoScreenState extends State<SettingsAccountInfoScreen> {
  final _name = TextEditingController(text: 'You');
  final _username = TextEditingController(text: 'you');
  final _bio = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    // TODO(api): PATCH /users/me with { name, username, bio } once endpoint
    // is wired into UsersApi.
    saveAndPop(context, 'Account info saved');
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Account Info',
      footer: SettingsPrimaryButton(label: 'Save', onTap: _save),
      children: [
        SettingsTextField(
          label: 'Display name',
          controller: _name,
          hint: 'How others see you',
        ),
        SettingsTextField(
          label: 'Username',
          controller: _username,
          hint: '3–20 letters / numbers / underscores',
        ),
        SettingsTextField(
          label: 'Bio',
          controller: _bio,
          hint: 'A line or two about you',
          maxLines: 4,
        ),
      ],
    );
  }
}
