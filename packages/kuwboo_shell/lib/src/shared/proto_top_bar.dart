import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/proto_theme.dart';
import '../data/proto_demo_data.dart';
import '../state/local_avatar_provider.dart';
import '../state/proto_state_provider.dart';
import '../routes/proto_routes.dart';
import '../testing/shell_test_ids.dart';

/// Interactive top bar matching the Kuwboo design.
/// YoYo icon LEFT (doubles as area/list toggle), Profile avatar RIGHT, Chat with badge.
///
/// [ConsumerWidget] so the profile avatar can watch [localAvatarProvider]
/// and surface the registration-picked photo instead of the stock demo
/// image. Keeps the signed-in user's face on screen everywhere the top
/// bar appears, without threading the bytes through every caller.
class ProtoTopBar extends ConsumerWidget {
  final ProtoModule activeModule;
  final bool transparent;

  const ProtoTopBar({
    super.key,
    required this.activeModule,
    this.transparent = false,
  });

  String _title() {
    switch (activeModule) {
      case ProtoModule.video:
        return 'KUWBOO';
      case ProtoModule.dating:
        return 'DATING';
      case ProtoModule.yoyo:
        return 'YOYO';
      case ProtoModule.social:
        return 'SOCIAL';
      case ProtoModule.shop:
        return 'BUY & SELL';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final localAvatarBytes = ref.watch(localAvatarProvider);

    // In transparent/overlay mode, no background — radar flows behind everything.
    // Icons get frosted backings so they remain legible over arbitrary backgrounds.
    if (transparent) {
      return Padding(
        padding: EdgeInsets.only(top: safeTop + 6, left: 16, right: 16, bottom: 6),
        child: _buildNavContent(context, state, theme, localAvatarBytes, withShadows: true),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: safeTop, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.text.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: _buildNavContent(context, state, theme, localAvatarBytes),
    );
  }

  Widget _buildNavContent(
    BuildContext context,
    PrototypeStateProvider state,
    ProtoTheme theme,
    Uint8List? localAvatarBytes, {
    bool withShadows = false,
  }) {
    // When transparent, give icons a subtle frosted backing so they pop over radar
    Widget iconBacking(Widget child) {
      if (!withShadows) return child;
      return Container(
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: child,
      );
    }

    // Title gets a subtle text shadow when floating over radar
    final titleStyle = theme.label.copyWith(
      fontSize: 14,
      letterSpacing: 2,
      color: theme.text,
      shadows: withShadows
          ? [Shadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)]
          : null,
    );

    return Row(
      children: [
        // YoYo icon — toggles area/list when in YoYo, otherwise jumps to YoYo
        _YoyoIconToggle(
          activeModule: activeModule,
          isYoyoAreaView: state.isYoyoAreaView,
          onTap: () {
            if (activeModule == ProtoModule.yoyo) {
              state.onYoyoViewToggle();
            } else {
              state.switchModule(ProtoModule.yoyo);
            }
          },
          theme: theme,
        ),

        const Spacer(),

        // Title
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _title(),
                key: ValueKey(_title()),
                style: titleStyle,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Chat icon with badge
        Semantics(
          identifier: ShellIds.topbarChatIcon,
          label: 'Chat inbox, 3 unread messages',
          button: true,
          child: GestureDetector(
            onTap: () => state.push(ProtoRoutes.chatInbox),
            child: iconBacking(SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      theme.icons.chatBubbleOutline,
                      size: 22,
                      color: withShadows ? theme.text : theme.textSecondary,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
        const SizedBox(width: 8),

        // Profile avatar with notification dot — goes directly to profile
        Semantics(
          identifier: ShellIds.topbarProfile,
          label: 'My profile',
          button: true,
          child: GestureDetector(
            onTap: () => PrototypeStateProvider.of(context)
                .push(ProtoRoutes.profileMy),
            child: iconBacking(SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: withShadows
                              ? theme.surface.withValues(alpha: 0.8)
                              : theme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: localAvatarBytes != null
                              ? MemoryImage(localAvatarBytes) as ImageProvider
                              : const NetworkImage(
                                  ProtoDemoData.currentUserAvatar,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }
}

/// The YoYo compass icon that doubles as an area/list toggle.
/// Shows a fading label on toggle, and a dark mask in list mode.
class _YoyoIconToggle extends StatefulWidget {
  final ProtoModule activeModule;
  final bool isYoyoAreaView;
  final VoidCallback onTap;
  final ProtoTheme theme;

  const _YoyoIconToggle({
    required this.activeModule,
    required this.isYoyoAreaView,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_YoyoIconToggle> createState() => _YoyoIconToggleState();
}

class _YoyoIconToggleState extends State<_YoyoIconToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _labelController;
  late Animation<double> _labelOpacity;
  String _lastLabel = '';

  @override
  void initState() {
    super.initState();
    _labelController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _labelOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_labelController);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_YoyoIconToggle old) {
    super.didUpdateWidget(old);
    // Show label when view mode changes while in YoYo
    if (old.isYoyoAreaView != widget.isYoyoAreaView &&
        widget.activeModule == ProtoModule.yoyo) {
      _lastLabel = widget.isYoyoAreaView ? 'Area' : 'List';
      _labelController.forward(from: 0);
    }
    // Show label when first entering YoYo
    if (old.activeModule != ProtoModule.yoyo &&
        widget.activeModule == ProtoModule.yoyo) {
      _lastLabel = 'Area';
      _labelController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isYoyo = widget.activeModule == ProtoModule.yoyo;
    final isListMode = isYoyo && !widget.isYoyoAreaView;
    final theme = widget.theme;

    return Semantics(
      identifier: ShellIds.topbarYoyoToggle,
      label: isYoyo
          ? (isListMode ? 'Switch to area view' : 'Switch to list view')
          : 'Go to YoYo',
      button: true,
      child: GestureDetector(
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isListMode
                  ? theme.secondary.withValues(alpha: 0.5)
                  : isYoyo
                      ? theme.secondary.withValues(alpha: 0.15)
                      : theme.background,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isListMode ? theme.icons.viewList : Icons.explore_rounded,
                key: ValueKey(isListMode),
                size: 20,
                color: isYoyo ? theme.secondary : theme.textSecondary,
              ),
            ),
          ),
          // Fading label
          AnimatedBuilder(
            animation: _labelOpacity,
            builder: (context, child) {
              if (_labelController.isDismissed || _lastLabel.isEmpty) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: _labelOpacity.value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    _lastLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.secondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}
