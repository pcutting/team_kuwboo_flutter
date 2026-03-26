import 'package:flutter/material.dart';
import '../proto_theme.dart';
import '../prototype_demo_data.dart';
import '../prototype_state.dart';
import '../prototype_routes.dart';
import 'proto_dialogs.dart';

/// Interactive top bar matching the Kuwboo design.
/// YoYo icon LEFT (doubles as area/list toggle), Profile avatar RIGHT, Chat with badge.
class ProtoTopBar extends StatelessWidget {
  final ProtoModule activeModule;

  const ProtoTopBar({
    super.key,
    required this.activeModule,
  });

  String _title(int yoyoMode) {
    switch (activeModule) {
      case ProtoModule.video:
        return 'KUWBOO';
      case ProtoModule.dating:
        return 'DATING';
      case ProtoModule.yoyo:
        return yoyoMode == 1 ? 'INNER CIRCLE' : 'YOYO';
      case ProtoModule.social:
        return 'SOCIAL';
      case ProtoModule.shop:
        return 'BUY & SELL';
    }
  }

  static const _warmAmber = Color(0xFFD4A04A);
  static const _warmGold = Color(0xFFE8C547);

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final isInnerCircle = activeModule == ProtoModule.yoyo && state.yoyoMode == 1;

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        // Warm gradient overlay for Inner Circle mode
        gradient: isInnerCircle
            ? LinearGradient(
                colors: [
                  _warmAmber.withValues(alpha: 0.15),
                  _warmGold.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border(
          bottom: BorderSide(
            color: isInnerCircle
                ? _warmAmber.withValues(alpha: 0.15)
                : theme.text.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          // YoYo icon — toggles area/list when in YoYo Social, or shows people icon in Inner Circle
          if (isInnerCircle)
            _InnerCircleIcon(theme: theme)
          else
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

          // Title + mode toggle icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _title(state.yoyoMode),
                  key: ValueKey(_title(state.yoyoMode)),
                  style: theme.label.copyWith(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: isInnerCircle ? _warmAmber : theme.text,
                  ),
                ),
              ),
              // Mode toggle — only visible in YoYo module
              if (activeModule == ProtoModule.yoyo) ...[
                const SizedBox(width: 8),
                _YoyoModeToggleIcon(
                  isInnerCircle: isInnerCircle,
                  onTap: () {
                    state.onYoyoModeChanged(state.yoyoMode == 0 ? 1 : 0);
                  },
                ),
              ],
            ],
          ),

          const Spacer(),

          // Chat icon with badge
          Semantics(
            label: 'Chat inbox, 3 unread messages',
            button: true,
            child: GestureDetector(
            onTap: () => state.push(ProtoRoutes.chatInbox),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      theme.icons.chatBubbleOutline,
                      size: 22,
                      color: theme.textSecondary,
                    ),
                  ),
                  // Unread badge
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
                      // Demo: static unread count
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
            ),
          ),
          ),
          const SizedBox(width: 8),

          // Profile avatar with notification dot — goes directly to profile
          Semantics(
            label: 'My profile, has notifications',
            button: true,
            child: GestureDetector(
            onTap: () => state.push(ProtoRoutes.profileMy),
            child: SizedBox(
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
                          color: theme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            ProtoDemoData.currentUserAvatar,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Notification dot
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
            ),
          ),
          ),
        ],
      ),
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

/// Small icon next to the title that toggles between Social and Inner Circle modes.
class _YoyoModeToggleIcon extends StatelessWidget {
  final bool isInnerCircle;
  final VoidCallback onTap;

  const _YoyoModeToggleIcon({
    required this.isInnerCircle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isInnerCircle ? 'Switch to YoYo Social mode' : 'Switch to Inner Circle mode',
      button: true,
      child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isInnerCircle
              ? ProtoTopBar._warmAmber.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: isInnerCircle
                ? ProtoTopBar._warmAmber.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isInnerCircle ? Icons.explore_rounded : Icons.family_restroom_rounded,
            key: ValueKey(isInnerCircle),
            size: 14,
            color: isInnerCircle
                ? ProtoTopBar._warmAmber
                : ProtoTheme.of(context).textSecondary,
          ),
        ),
      ),
    ),
    );
  }
}

/// Left icon shown in Inner Circle mode — people/shield icon.
class _InnerCircleIcon extends StatelessWidget {
  final ProtoTheme theme;

  const _InnerCircleIcon({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ProtoTopBar._warmAmber.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_rounded,
        size: 20,
        color: ProtoTopBar._warmAmber,
      ),
    );
  }
}
