import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'profile_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final Set<String> _selectedInterestIds = <String>{};
  final Set<String> _selectedInterestNames = <String>{};

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _seedFromUser(User user) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = user.name ?? '';
    final username = user.username;
    _usernameController.text = username == null
        ? ''
        : (username.startsWith('@') ? username.substring(1) : username);
    _bioController.text = user.bio ?? '';
  }

  void _seedInterests(List<Interest> interests) {
    if (_selectedInterestIds.isNotEmpty) return;
    for (final interest in interests) {
      _selectedInterestIds.add(interest.id);
      _selectedInterestNames.add(interest.label);
    }
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final usersApi = ref.read(usersApiProvider);
    final interestsApi = ref.read(interestsApiProvider);

    try {
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim();
      final bio = _bioController.text.trim();

      await usersApi.patchMe(
        PatchMeDto(
          displayName: name.isEmpty ? null : name,
          username: username.isEmpty ? null : username,
          bio: bio.isEmpty ? null : bio,
        ),
      );

      // Persist interests selection. The selectMany endpoint replaces
      // the full declared set with the ids supplied.
      if (_selectedInterestIds.isNotEmpty) {
        await interestsApi.selectMany(
          SelectInterestsDto(interestIds: _selectedInterestIds.toList()),
        );
      }

      // Refresh cached user + interests so the calling screen sees updates.
      ref.invalidate(meProvider);
      ref.invalidate(myInterestsProvider);

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final meAsync = ref.watch(meProvider);
    final myInterestsAsync = ref.watch(myInterestsProvider);
    final catalogueAsync = ref.watch(_interestCatalogueProvider);

    meAsync.whenData(_seedFromUser);
    myInterestsAsync.whenData(_seedInterests);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.surface,
        child: Column(
          children: [
            ProtoSubBar(
              title: 'Edit Profile',
              actions: [
                GestureDetector(
                  onTap: _saving ? null : _onSave,
                  child: _saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(theme.primary),
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Photos grid
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: theme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.text.withValues(alpha: 0.1),
                              ),
                            ),
                            child:
                                i == 0 && meAsync.valueOrNull?.avatarUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ProtoNetworkImage(
                                      imageUrl: meAsync.valueOrNull!.avatarUrl!,
                                    ),
                                  )
                                : Icon(
                                    theme.icons.add,
                                    size: 28,
                                    color: theme.textTertiary,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _EditField(
                    label: 'Name',
                    controller: _nameController,
                    hint: 'Your name',
                  ),
                  _EditField(
                    label: 'Username',
                    controller: _usernameController,
                    hint: 'username',
                    prefix: '@',
                  ),
                  _EditField(
                    label: 'Bio',
                    controller: _bioController,
                    hint: 'Tell others about yourself',
                    multiline: true,
                  ),

                  const SizedBox(height: 16),
                  Text('Interests', style: theme.title),
                  const SizedBox(height: 8),
                  _InterestsPicker(
                    catalogueAsync: catalogueAsync,
                    selectedIds: _selectedInterestIds,
                    selectedNames: _selectedInterestNames,
                    onToggleId: (id) {
                      setState(() {
                        if (_selectedInterestIds.contains(id)) {
                          _selectedInterestIds.remove(id);
                        } else {
                          _selectedInterestIds.add(id);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Catalogue of all available interests (for the editor's chip picker).
/// Falls back to an empty list on error so the user can still save the
/// profile form (interests just won't render).
final _interestCatalogueProvider = FutureProvider.autoDispose<List<Interest>>((
  ref,
) async {
  try {
    return await ref.watch(interestsApiProvider).listAll();
  } catch (_) {
    return const <Interest>[];
  }
});

class _InterestsPicker extends StatelessWidget {
  final AsyncValue<List<Interest>> catalogueAsync;
  final Set<String> selectedIds;
  final Set<String> selectedNames;
  final ValueChanged<String> onToggleId;

  const _InterestsPicker({
    required this.catalogueAsync,
    required this.selectedIds,
    required this.selectedNames,
    required this.onToggleId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return catalogueAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) {
        // Fallback — let the user at least see their locally-tracked selection.
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedNames
              .map(
                (name) =>
                    _interestChip(context, name, isSelected: true, onTap: null),
              )
              .toList(),
        );
      },
      data: (catalogue) {
        if (catalogue.isEmpty) {
          return Text(
            'No interests available right now.',
            style: theme.caption.copyWith(color: theme.textSecondary),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: catalogue.map((interest) {
            final isSelected = selectedIds.contains(interest.id);
            return _interestChip(
              context,
              interest.label,
              isSelected: isSelected,
              onTap: () => onToggleId(interest.id),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _interestChip(
    BuildContext context,
    String label, {
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.background,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: theme.text.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final bool multiline;

  const _EditField({
    required this.label,
    required this.controller,
    required this.hint,
    this.prefix,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: multiline ? 8 : 4,
            ),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.text.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: controller,
              maxLines: multiline ? 4 : 1,
              minLines: multiline ? 3 : 1,
              style: theme.body.copyWith(color: theme.text),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: theme.body.copyWith(color: theme.textTertiary),
                prefixText: prefix,
                prefixStyle: theme.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
