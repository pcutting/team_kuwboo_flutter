import 'package:dio/dio.dart';
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
    // Strip any stored leading `@` — canonical form is without prefix,
    // and the field now renders `@` as a decoration so showing `@@phil`
    // would be confusing.
    _username.text = _normalizeUsername(user.username ?? '');
    _bio.text = user.bio ?? '';
    _seeded = true;
  }

  /// Strip a leading `@` if present — users habitually type it because
  /// the handle renders as `@phil_admin` elsewhere, but the backend regex
  /// `[a-zA-Z0-9_.]` rejects `@` and 409s with `invalid_username`.
  String _normalizeUsername(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('@')) return trimmed.substring(1);
    return trimmed;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final username = _normalizeUsername(_username.text);
      await ref
          .read(usersApiProvider)
          .patchMe(
            PatchMeDto(
              displayName: _name.text.trim(),
              username: username.isEmpty ? null : username,
              bio: _bio.text.trim(),
            ),
          );
      // Await the refetched user so we don't pop while meProvider is still
      // loading — otherwise callers that re-watch immediately after us
      // (e.g. the settings list, top nav) may render stale values until
      // their own rebuild arrives.
      ref.invalidate(meProvider);
      await ref.read(meProvider.future);
      if (!mounted) return;
      saveAndPop(context, 'Account info saved');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_friendlyError(e))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  /// Map backend validation codes to copy the user can actually act on.
  /// The raw DioException toString exposes HTTP internals that read as
  /// "something broke" rather than "fix your input".
  String _friendlyError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['code'];
      final msg = data['message'];
      if (code == 'invalid_username') {
        return 'Username must be 3–30 characters, letters / digits / _ / . only.';
      }
      if (code == 'username_taken') {
        return 'That username is already taken.';
      }
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) return 'Session expired — sign in again.';
    return 'Save failed — please try again.';
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
              prefixText: '@',
              hint: 'phil_admin',
              helper: '3–30 characters. Letters, digits, underscores, dots.',
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
