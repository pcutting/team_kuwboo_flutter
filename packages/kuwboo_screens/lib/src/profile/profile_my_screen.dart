import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
import 'profile_providers.dart';

class ProfileMyScreen extends ConsumerStatefulWidget {
  const ProfileMyScreen({super.key});

  @override
  ConsumerState<ProfileMyScreen> createState() => _ProfileMyScreenState();
}

class _ProfileMyScreenState extends ConsumerState<ProfileMyScreen> {
  final ImagePicker _picker = ImagePicker();

  /// Locally-selected avatar bytes (session-only). When non-null, these
  /// override whatever comes from `meProvider`. Cleared by "Remove photo".
  Uint8List? _localAvatarBytes;

  /// True when "Remove photo" was tapped in this session — suppresses the
  /// backend avatar URL and shows the default placeholder instead.
  bool _avatarRemoved = false;

  Future<void> _showAvatarSheet(BuildContext context) async {
    final theme = ProtoTheme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.text.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _SheetAction(
                icon: theme.icons.cameraAlt,
                label: 'Take photo',
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await _pickFrom(ImageSource.camera);
                },
              ),
              _SheetAction(
                icon: Icons.photo_library_outlined,
                label: 'Choose from library',
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await _pickFrom(ImageSource.gallery);
                },
              ),
              _SheetAction(
                icon: Icons.delete_outline_rounded,
                label: 'Remove photo',
                destructive: true,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  setState(() {
                    _localAvatarBytes = null;
                    _avatarRemoved = true;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _localAvatarBytes = bytes;
        _avatarRemoved = false;
      });
      // TODO(auth): POST bytes to /users/me/avatar once the endpoint is
      // live, then invalidate meProvider on success.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Couldn\'t open picker: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final meAsync = ref.watch(meProvider);
    final unreadAsync = ref.watch(unreadNotificationCountProvider);

    // Material ancestor is required by Switch + DefaultTextStyle — the proto
    // shell otherwise wraps only a bare Container, which lets Text fall back
    // to the yellow-underline debug style and crashes the Dark Mode switch
    // with "No Material widget found".
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(title: 'Profile'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(meProvider);
                  ref.invalidate(unreadNotificationCountProvider);
                  await ref.read(meProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 20),
                    // Avatar — tap to change (library / camera / remove)
                    Center(
                      child: Semantics(
                        identifier: ScreensIds.profileMyAvatar,
                        image: true,
                        button: true,
                        label: 'Profile photo — tap to change',
                        child: GestureDetector(
                          onTap: () => _showAvatarSheet(context),
                          child: Stack(
                            children: [
                              _buildAvatar(meAsync.valueOrNull, theme),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.background,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    theme.icons.cameraAlt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Semantics(
                        identifier: ScreensIds.profileMyName,
                        label: 'Display name',
                        child: Text(
                          _displayName(meAsync.valueOrNull),
                          style: theme.headline.copyWith(fontSize: 24),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        _handle(meAsync.valueOrNull),
                        style: theme.body,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats (still placeholder — counts endpoint not wired yet)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: theme.cardDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Semantics(
                            identifier: ScreensIds.profileMyStat('posts'),
                            value: '—',
                            label: 'Posts',
                            child: _Stat(count: '—', label: 'Posts'),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: theme.text.withValues(alpha: 0.08),
                          ),
                          Semantics(
                            identifier: ScreensIds.profileMyStat('followers'),
                            value: '—',
                            label: 'Followers',
                            child: _Stat(count: '—', label: 'Followers'),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: theme.text.withValues(alpha: 0.08),
                          ),
                          Semantics(
                            identifier: ScreensIds.profileMyStat('following'),
                            value: '—',
                            label: 'Following',
                            child: _Stat(count: '—', label: 'Following'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu items
                    Semantics(
                      identifier: ScreensIds.profileMyEdit,
                      button: true,
                      label: 'Edit Profile',
                      child: _MenuItem(
                        icon: theme.icons.editOutline,
                        label: 'Edit Profile',
                        onTap: () => context.go(ProtoRoutes.profileEdit),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final unreadCount = unreadAsync.when(
                          data: (count) => count,
                          loading: () => 0,
                          error: (_, __) => 0,
                        );
                        return Semantics(
                          identifier: ScreensIds.profileMyNotifications,
                          button: true,
                          label: 'Notifications',
                          value: unreadCount > 0 ? '$unreadCount unread' : null,
                          child: _MenuItemWithBadge(
                            icon: theme.icons.notificationsOutline,
                            label: 'Notifications',
                            badgeCount: unreadCount,
                            onTap: () =>
                                context.go(ProtoRoutes.profileNotifications),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: theme.icons.chatBubbleOutline,
                      label: 'Messages',
                      onTap: () => context.go(ProtoRoutes.chatInbox),
                    ),
                    // TODO: enable when Listings + Saved features ship
                    // _MenuItem(icon: theme.icons.storefrontOutline, label: 'My Listings', onTap: () {}),
                    // _MenuItem(icon: theme.icons.favoriteOutline, label: 'Saved Items', onTap: () {}),
                    _MenuItem(
                      icon: theme.icons.campaign,
                      label: 'Promote',
                      onTap: () => context.go(ProtoRoutes.sponsoredHub),
                    ),
                    _DarkModeToggle(),
                    _MenuItem(
                      icon: theme.icons.settings,
                      label: 'Settings',
                      onTap: () => context.go(ProtoRoutes.profileSettings),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, ProtoTheme theme) {
    const fallbackUrl =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop';

    if (_localAvatarBytes != null) {
      return Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: MemoryImage(_localAvatarBytes!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final url = _avatarRemoved ? fallbackUrl : (user?.avatarUrl ?? fallbackUrl);
    return ProtoAvatar(radius: 48, imageUrl: url);
  }

  String _displayName(User? user) {
    if (user == null) return 'Loading...';
    final name = user.name;
    if (name != null && name.trim().isNotEmpty) return name;
    final username = user.username;
    if (username != null && username.trim().isNotEmpty) return username;
    return 'You';
  }

  String _handle(User? user) {
    final username = user?.username;
    if (username == null || username.trim().isEmpty) return '';
    return username.startsWith('@') ? username : '@$username';
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final color = destructive ? theme.accent : theme.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.title.copyWith(fontSize: 15, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: ProtoTheme.of(context).title.copyWith(fontSize: 18)),
        Text(label, style: ProtoTheme.of(context).caption),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.primary),
            const SizedBox(width: 14),
            Text(label, style: theme.title.copyWith(fontSize: 15)),
            const Spacer(),
            Icon(theme.icons.chevronRight, size: 22, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;
  const _MenuItemWithBadge({
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.primary),
            const SizedBox(width: 14),
            Text(label, style: theme.title.copyWith(fontSize: 15)),
            if (badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(theme.icons.chevronRight, size: 22, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: theme.cardDecoration,
      child: Row(
        children: [
          Icon(
            state.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.dark_mode_outlined,
            size: 22,
            color: state.isDarkMode ? theme.secondary : theme.primary,
          ),
          const SizedBox(width: 14),
          Text('Dark Mode', style: theme.title.copyWith(fontSize: 15)),
          const Spacer(),
          Switch(
            value: state.isDarkMode,
            onChanged: state.onDarkModeChanged,
            activeThumbColor: theme.secondary,
          ),
        ],
      ),
    );
  }
}
