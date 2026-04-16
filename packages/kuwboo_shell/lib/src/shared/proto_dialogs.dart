import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/proto_theme.dart';
import '../theme/brand_colors.dart';
import '../state/proto_state_provider.dart';
import '../routes/proto_routes.dart';
import '../testing/shell_test_ids.dart';

/// Modal bottom sheet presenting share options with platform icons.
/// Each option shows a SnackBar confirming the simulated share action.
class ProtoShareSheet {
  static void show(BuildContext context) {
    final theme = ProtoTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Share to', style: theme.title),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShareOption(icon: theme.icons.chatOutline, label: 'WhatsApp', color: BrandColors.whatsApp, theme: theme),
                    _ShareOption(icon: theme.icons.cameraAltOutline, label: 'Instagram', color: BrandColors.instagram, theme: theme),
                    _ShareOption(icon: theme.icons.messageOutline, label: 'Messages', color: BrandColors.iosMessages, theme: theme),
                    _ShareOption(icon: theme.icons.linkOutline, label: 'Copy Link', color: theme.textSecondary, theme: theme),
                    _ShareOption(icon: theme.icons.moreHoriz, label: 'More', color: theme.textTertiary, theme: theme),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ProtoTheme theme;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: ShellIds.shareOption(label),
      label: 'Share via $label',
      button: true,
      child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ProtoToast.show(context, icon, 'Shared via $label');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.caption.copyWith(fontSize: 10)),
        ],
      ),
    ),
    );
  }
}

/// Self-dismissing overlay toast. Appears at top center, fades in/out over 1.5s.
class ProtoToast {
  static void show(BuildContext context, IconData icon, String message) {
    final overlay = Overlay.of(context);
    final theme = ProtoTheme.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        icon: icon,
        message: message,
        theme: theme,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final IconData icon;
  final String message;
  final ProtoTheme theme;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.icon,
    required this.message,
    required this.theme,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade in
    Future.microtask(() {
      if (mounted) setState(() => _opacity = 1.0);
    });
    // Fade out after 1s visible
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
    // Remove after fade-out completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 40,
      right: 40,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.theme.text.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(widget.theme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: widget.theme.body.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple centered confirmation dialog. Returns true if confirmed, false otherwise.
class ProtoConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final theme = ProtoTheme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.title.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      identifier: ShellIds.dialogConfirmCancel,
                      label: 'Cancel',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.text.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Cancel', style: theme.title.copyWith(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      identifier: ShellIds.dialogConfirmConfirm,
                      label: 'Confirm',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Confirm', style: theme.button.copyWith(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }
}

/// Bottom sheet menu shown when tapping the profile avatar in the top bar.
/// Provides quick access to profile, settings, and a dark mode toggle.
///
/// In debug builds an additional "Reset onboarding (dev)" item appears when
/// [onDevReset] is supplied. The callback is wired from the mobile app
/// (it knows about Riverpod's `authProvider`, which this package intentionally
/// does not import) and is expected to clear secure-storage tokens, invalidate
/// the auth provider, and route back to `/auth/welcome`. The item is gated on
/// `kDebugMode` too so the menu item never ships in TestFlight/App Store
/// builds even if a future caller forgets to null-check the callback.
class ProtoProfileMenu {
  static void show(BuildContext context, {VoidCallback? onDevReset}) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusLg)),
      ),
      builder: (ctx) {
        return _ProfileMenuContent(
          theme: theme,
          state: state,
          onDevReset: onDevReset,
        );
      },
    );
  }
}

class _ProfileMenuContent extends StatefulWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  final VoidCallback? onDevReset;

  const _ProfileMenuContent({
    required this.theme,
    required this.state,
    this.onDevReset,
  });

  @override
  State<_ProfileMenuContent> createState() => _ProfileMenuContentState();
}

class _ProfileMenuContentState extends State<_ProfileMenuContent> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.state.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final state = widget.state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // View Profile
            _ProfileMenuItem(
              identifier: ShellIds.profileMenuViewProfile,
              icon: theme.icons.personOutline,
              label: 'View Profile',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                state.push(ProtoRoutes.profileMy);
              },
            ),
            // Settings
            _ProfileMenuItem(
              identifier: ShellIds.profileMenuSettings,
              icon: theme.icons.settings,
              label: 'Settings',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                state.push(ProtoRoutes.profileSettings);
              },
            ),
            // Dark Mode toggle
            Semantics(
              identifier: ShellIds.profileMenuDarkMode,
              label: 'Dark Mode',
              toggled: _isDarkMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.text.withValues(alpha: 0.04))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, size: 20, color: _isDarkMode ? theme.secondary : theme.textSecondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Dark Mode', style: theme.body.copyWith(color: theme.text, fontSize: 14)),
                    ),
                    Switch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        state.onDarkModeChanged(value);
                        setState(() => _isDarkMode = value);
                      },
                      activeThumbColor: theme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            // Dev-only: reset onboarding. Double-gated on kDebugMode and a
            // callback being supplied so it can never appear in release
            // builds. Useful for re-running the auth flow without
            // uninstalling the app.
            if (kDebugMode && widget.onDevReset != null)
              _ProfileMenuItem(
                icon: Icons.refresh_rounded,
                label: 'Reset onboarding (dev)',
                theme: theme,
                onTap: () {
                  Navigator.pop(context);
                  widget.onDevReset!();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ProtoTheme theme;
  final VoidCallback onTap;
  final String? identifier;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: identifier,
      label: label,
      button: true,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.text.withValues(alpha: 0.04))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: theme.body.copyWith(color: theme.text, fontSize: 14)),
            ),
            Icon(theme.icons.chevronRight, size: 20, color: theme.textTertiary),
          ],
        ),
      ),
    ),
    );
  }
}
