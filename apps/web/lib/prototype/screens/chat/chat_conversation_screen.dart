import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_demo_data.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import '../../shared/proto_scaffold.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  int _variant = 0; // 0 = v1 (simple), 1 = v2 (full-featured)
  ValueNotifier<int>? _variantCount;
  ValueNotifier<int>? _variantIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = PrototypeStateProvider.maybeOf(context);
    if (provider != null && _variantIndex == null) {
      _variantCount = provider.screenVariantCount;
      _variantIndex = provider.screenVariantIndex;
      _variant = _variantIndex!.value.clamp(0, 1);
      _variantIndex!.addListener(_onExternalVariantChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantCount!.value = 2;
      });
    }
  }

  void _onExternalVariantChange() {
    final idx = _variantIndex?.value ?? 0;
    if (idx != _variant && idx >= 0 && idx < 2) {
      setState(() => _variant = idx);
    }
  }

  @override
  void dispose() {
    _variantIndex?.removeListener(_onExternalVariantChange);
    _variantCount?.value = 0;
    super.dispose();
  }

  void _setVariant(int v) {
    setState(() => _variant = v);
    _variantIndex?.value = v;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final messages = ProtoDemoData.messages;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          // Header: v1 = ProtoSubBar, v2 = custom two-row header
          _variant == 0
              ? _SimpleHeader(
                  theme: theme,
                  variant: _variant,
                  onVariantChanged: _setVariant,
                )
              : _ChatHeader(
                  theme: theme,
                  variant: _variant,
                  onVariantChanged: _setVariant,
                ),
          // Purchase badge: v2 only
          if (_variant == 1) _PurchaseBadge(theme: theme),
          // Messages
          Expanded(
            child: _variant == 0
                ? _SimpleMessageList(theme: theme, messages: messages)
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      for (int i = 0; i < messages.length; i++)
                        _swipeableMessage(
                          context,
                          theme,
                          messages[i],
                          i,
                          _MessageBubble(
                            theme: theme,
                            msg: messages[i],
                            index: i,
                            allMessages: messages,
                          ),
                        ),
                      _TypingIndicator(theme: theme),
                    ],
                  ),
          ),
          // Input bar: v1 = simple, v2 = rich
          _variant == 0
              ? _SimpleInputBar(theme: theme)
              : _RichInputBar(theme: theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Variant Toggle Buttons (reusable) ─────────────────────────────────────────

Widget _buildVariantToggle(
  ProtoTheme theme,
  int activeVariant,
  void Function(int) onVariantChanged,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < 2; i++) ...[
        GestureDetector(
          onTap: () => onVariantChanged(i),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: i == activeVariant ? theme.primary : theme.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: i == activeVariant
                    ? theme.primary
                    : theme.textTertiary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: i == activeVariant ? Colors.white : theme.textTertiary,
                ),
              ),
            ),
          ),
        ),
        if (i < 1) const SizedBox(width: 4),
      ],
    ],
  );
}

// ── Shared swipe-to-delete wrapper (used by both v1 and v2) ─────────────────

Widget _swipeableMessage(
  BuildContext context,
  ProtoTheme theme,
  DemoMessage msg,
  int index,
  Widget child,
) {
  return Dismissible(
    key: ValueKey('msg-$index'),
    direction: msg.isMine
        ? DismissDirection.endToStart
        : DismissDirection.startToEnd,
    confirmDismiss: (_) => _showDeleteSheet(context, theme, msg),
    background: Container(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      padding: msg.isMine
          ? const EdgeInsets.only(right: 20)
          : const EdgeInsets.only(left: 20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          Icon(Icons.delete_outline_rounded, color: theme.accent, size: 22),
    ),
    child: child,
  );
}

Future<bool> _showDeleteSheet(
    BuildContext context, ProtoTheme theme, DemoMessage msg) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Delete message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ProtoPressButton(
            onTap: () {
              Navigator.pop(ctx);
              ProtoToast.show(
                context,
                Icons.delete_outline_rounded,
                'Deleted for you',
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 22, color: theme.textSecondary),
                  const SizedBox(width: 14),
                  Text(
                    'Delete for me',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (msg.isMine)
            ProtoPressButton(
              onTap: () {
                Navigator.pop(ctx);
                ProtoToast.show(
                  context,
                  Icons.delete_forever_rounded,
                  'Deleted for everyone',
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 22, color: theme.accent),
                    const SizedBox(width: 14),
                    Text(
                      'Delete for everyone',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
  return false;
}

// ── V1 Simple Header (ProtoSubBar + toggle) ─────────────────────────────────

class _SimpleHeader extends StatelessWidget {
  final ProtoTheme theme;
  final int variant;
  final ValueChanged<int> onVariantChanged;

  const _SimpleHeader({
    required this.theme,
    required this.variant,
    required this.onVariantChanged,
  });

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    // Mirrors _ChatHeader Row 1 layout so toggle stays centered when switching
    return Container(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 12, bottom: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => state.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(theme.icons.arrowBack, size: 16, color: theme.text),
            ),
          ),
          const SizedBox(width: 8),
          Text('Maya', style: theme.title),
          const Spacer(),
          _buildVariantToggle(theme, variant, onVariantChanged),
          const Spacer(),
          ProtoPressButton(
            onTap: () => _showMoreMenu(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(theme.icons.moreHoriz, size: 18, color: theme.text),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _menuItem(ctx, Icons.block_rounded, 'Block', theme.accent),
            _menuItem(ctx, Icons.flag_rounded, 'Report', theme.accent),
            _menuItem(ctx, Icons.delete_sweep_rounded, 'Clear chat', theme.textSecondary),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, Color color) {
    return ProtoPressButton(
      onTap: () {
        Navigator.pop(context);
        ProtoToast.show(context, icon, '$label tapped');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── V2 Custom Chat Header (with toggle) ─────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final ProtoTheme theme;
  final int variant;
  final ValueChanged<int> onVariantChanged;

  const _ChatHeader({
    required this.theme,
    required this.variant,
    required this.onVariantChanged,
  });

  static const _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop';

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 12, bottom: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Back + Toggle + More menu
          Row(
            children: [
              GestureDetector(
                onTap: () => state.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme.icons.arrowBack, size: 16, color: theme.text),
                ),
              ),
              const Spacer(),
              _buildVariantToggle(theme, variant, onVariantChanged),
              const Spacer(),
              ProtoPressButton(
                onTap: () => ProtoToast.show(
                  context,
                  theme.icons.moreHoriz,
                  'More options would open',
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme.icons.moreHoriz, size: 18, color: theme.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Avatar + Name + Online
          ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.profileMy),
            child: Row(
              children: [
                ProtoAvatar(
                  radius: 22,
                  imageUrl: _avatarUrl,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Maya', style: theme.title),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: theme.successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online',
                          style: theme.caption.copyWith(
                            color: theme.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── V1 Simple Message List ──────────────────────────────────────────────────

class _SimpleMessageList extends StatelessWidget {
  final ProtoTheme theme;
  final List<DemoMessage> messages;

  const _SimpleMessageList({required this.theme, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (int i = 0; i < messages.length; i++)
          _swipeableMessage(
            context,
            theme,
            messages[i],
            i,
            _simpleBubble(messages[i]),
          ),
      ],
    );
  }

  Widget _simpleBubble(DemoMessage msg) {
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 240),
        decoration: BoxDecoration(
          color: msg.isMine ? theme.primary : theme.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: msg.isMine ? const Radius.circular(4) : null,
            bottomLeft: !msg.isMine ? const Radius.circular(4) : null,
          ),
          boxShadow: msg.isMine ? null : theme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: msg.isMine ? Colors.white : theme.text,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.timeAgo,
              style: TextStyle(
                fontSize: 10,
                color: msg.isMine
                    ? Colors.white.withValues(alpha: 0.6)
                    : theme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── V1 Simple Input Bar ─────────────────────────────────────────────────────

class _SimpleInputBar extends StatelessWidget {
  final ProtoTheme theme;
  const _SimpleInputBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              Icons.attach_file_rounded,
              'Attach file or take photo',
            ),
            child: Icon(Icons.attach_file_rounded, size: 22, color: theme.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Type a message...',
                style: theme.body.copyWith(color: theme.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              theme.icons.send,
              'Message would send',
            ),
            child: Icon(theme.icons.send, size: 24, color: theme.primary),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble with Read Receipts & Reaction ──────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ProtoTheme theme;
  final DemoMessage msg;
  final int index;
  final List<DemoMessage> allMessages;

  const _MessageBubble({
    required this.theme,
    required this.msg,
    required this.index,
    required this.allMessages,
  });

  @override
  Widget build(BuildContext context) {
    // Count which outgoing/incoming message this is (1-indexed)
    int outgoingNum = 0;
    int incomingNum = 0;
    for (int j = 0; j <= index; j++) {
      if (allMessages[j].isMine) {
        outgoingNum++;
      } else {
        incomingNum++;
      }
    }

    // Check if this is the last "Read" outgoing message
    bool isLastReadOutgoing = false;
    if (msg.isMine && outgoingNum <= 3) {
      int futureOutgoingCount = outgoingNum;
      for (int j = index + 1; j < allMessages.length; j++) {
        if (allMessages[j].isMine) {
          futureOutgoingCount++;
          break;
        }
      }
      isLastReadOutgoing = futureOutgoingCount > 3 || futureOutgoingCount == outgoingNum;
    }

    // Reaction pill on 3rd incoming message
    final showReaction = !msg.isMine && incomingNum == 3;

    return Column(
      crossAxisAlignment:
          msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment:
              msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => _showReactionPicker(context),
            onDoubleTap: () => ProtoToast.show(
              context,
              Icons.reply_rounded,
              'Reply to "${msg.text.length > 25 ? '${msg.text.substring(0, 25)}...' : msg.text}"',
            ),
            child: Container(
              margin: EdgeInsets.only(bottom: showReaction ? 2 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 240),
              decoration: BoxDecoration(
                color: msg.isMine ? theme.primary : theme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight:
                      msg.isMine ? const Radius.circular(4) : null,
                  bottomLeft:
                      !msg.isMine ? const Radius.circular(4) : null,
                ),
                boxShadow: msg.isMine ? null : theme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: msg.isMine ? Colors.white : theme.text,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.timeAgo,
                        style: TextStyle(
                          fontSize: 10,
                          color: msg.isMine
                              ? Colors.white.withValues(alpha: 0.6)
                              : theme.textTertiary,
                        ),
                      ),
                      if (msg.isMine) ...[
                        const SizedBox(width: 3),
                        _readReceiptIcon(outgoingNum),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Reaction pill
        if (showReaction)
          Container(
            margin: const EdgeInsets.only(left: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: theme.softShadow,
            ),
            child: Text(
              '\u2764\uFE0F 1',
              style: TextStyle(fontSize: 11, color: theme.text),
            ),
          ),
        // "Seen" label below last read outgoing message
        if (isLastReadOutgoing)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Text(
              'Seen 10:41 AM',
              style: TextStyle(fontSize: 10, color: theme.textTertiary),
            ),
          ),
      ],
    );
  }

  Widget _readReceiptIcon(int outgoingNum) {
    if (outgoingNum <= 3) {
      // Read — light blue double check (visible on any primary)
      return const Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Color(0xFF4FC3F7),
      );
    } else if (outgoingNum == 4) {
      // Delivered — semi-transparent double check
      return Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Colors.white.withValues(alpha: 0.5),
      );
    } else {
      // Sent — semi-transparent single check
      return Icon(
        Icons.done_rounded,
        size: 14,
        color: Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  void _showReactionPicker(BuildContext context) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ReactionOverlay(
        theme: theme,
        onReact: (emoji) {
          entry.remove();
          ProtoToast.show(context, Icons.emoji_emotions_rounded, 'Reacted $emoji');
        },
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

// ── Reaction Picker Overlay ───────────────────────────────────────────────────

class _ReactionOverlay extends StatelessWidget {
  final ProtoTheme theme;
  final void Function(String emoji) onReact;
  final VoidCallback onDismiss;

  const _ReactionOverlay({
    required this.theme,
    required this.onReact,
    required this.onDismiss,
  });

  static const _reactions = [
    '\u2764\uFE0F',
    '\uD83D\uDE02',
    '\uD83D\uDE2E',
    '\uD83D\uDC4D',
    '\uD83D\uDD25',
    '\uD83D\uDE22',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _reactions.map((emoji) {
                return ProtoPressButton(
                  onTap: () => onReact(emoji),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  final ProtoTheme theme;
  const _TypingIndicator({required this.theme});

  static const _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ProtoAvatar(
            radius: 8,
            imageUrl: _avatarUrl,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: theme.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0.4),
                const SizedBox(width: 4),
                _dot(0.7),
                const SizedBox(width: 4),
                _dot(1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: theme.textTertiary.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Rich Input Bar ────────────────────────────────────────────────────────────

class _RichInputBar extends StatelessWidget {
  final ProtoTheme theme;
  const _RichInputBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          _mediaIcon(
            context,
            theme.icons.cameraAlt,
            'Camera would open',
          ),
          const SizedBox(width: 6),
          _mediaIcon(
            context,
            theme.icons.photoLibrary,
            'Photo/video picker would open',
          ),
          const SizedBox(width: 6),
          _mediaIcon(
            context,
            Icons.mic_none_rounded,
            'Hold to record voice note',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Type a message...',
                style: theme.body.copyWith(color: theme.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              theme.icons.send,
              'Message would send',
            ),
            child: Icon(theme.icons.send, size: 24, color: theme.primary),
          ),
        ],
      ),
    );
  }

  Widget _mediaIcon(BuildContext context, IconData icon, String toast) {
    return ProtoPressButton(
      onTap: () => ProtoToast.show(context, icon, toast),
      child: Icon(icon, size: 22, color: theme.textSecondary),
    );
  }
}

// ── Purchase Badge (unchanged) ────────────────────────────────────────────────

class _PurchaseBadge extends StatelessWidget {
  final ProtoTheme theme;
  const _PurchaseBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ProtoNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=80&h=80&fit=crop',
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vintage Camera',
                  style: theme.title.copyWith(fontSize: 13),
                ),
                Row(
                  children: [
                    Text(
                      '\$85',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < 4
                            ? theme.icons.starFilled
                            : Icons.star_outline_rounded,
                        size: 12,
                        color: i < 4 ? theme.tertiary : theme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              theme.icons.starFilled,
              'Leave a review',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Review',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
