import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../profile_providers.dart';
import '_settings_page.dart';

/// Edit display name, username, bio. Birthday shown read-only (edit flows
/// through the auth birthday step because DOB is age-gated).
class SettingsAccountInfoScreen extends ConsumerStatefulWidget {
  const SettingsAccountInfoScreen({super.key});

  @override
  ConsumerState<SettingsAccountInfoScreen> createState() =>
      _SettingsAccountInfoScreenState();
}

class _SettingsAccountInfoScreenState
    extends ConsumerState<SettingsAccountInfoScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();

  /// True once we've seeded the text controllers from the loaded user.
  /// Prevents clobbering user edits if meProvider rebuilds mid-edit.
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _seedFrom(User user) {
    if (_seeded) return;
    _name.text = user.name ?? '';
    _username.text = user.username ?? '';
    _bio.text = user.bio ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(usersApiProvider)
          .patchMe(
            PatchMeDto(
              displayName: _name.text.trim(),
              username: _username.text.trim().isEmpty
                  ? null
                  : _username.text.trim(),
              bio: _bio.text.trim(),
            ),
          );
      ref.invalidate(meProvider);
      if (!mounted) return;
      saveAndPop(context, 'Account info saved');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final meAsync = ref.watch(meProvider);
    return meAsync.when(
      loading: () => _LoadingShell(theme: theme),
      error: (err, _) => SettingsPage(
        title: 'Account Info',
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Couldn\'t load your profile.\n$err',
                textAlign: TextAlign.center,
                style: theme.body.copyWith(color: theme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      data: (user) {
        _seedFrom(user);
        return SettingsPage(
          title: 'Account Info',
          footer: SettingsPrimaryButton(
            label: _saving ? 'Saving…' : 'Save',
            onTap: _saving ? () {} : _save,
            enabled: !_saving,
          ),
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
      },
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell({required this.theme});
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Account Info',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
