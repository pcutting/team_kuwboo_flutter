import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

// ── Data Model ─────────────────────────────────────────────────────────────

enum _ItemType {
  message,
  dateSeparator,
  offerSent,
  counterOffer,
  offerAccepted,
  meetupPending,
  shipPending,
  purchaseComplete,
}

class _ChatItem {
  final String? text;
  final String timeAgo;
  final bool isMine;
  final _ItemType type;
  final String? productTitle;
  final String? productImageUrl;
  final double? amount;
  final double? originalPrice;
  final String? statusLabel;
  final String? detailLine;

  const _ChatItem({
    this.text,
    this.timeAgo = '',
    this.isMine = false,
    this.type = _ItemType.message,
    this.productTitle,
    this.productImageUrl,
    this.amount,
    this.originalPrice,
    this.statusLabel,
    this.detailLine,
  });
}

// ── Conversation Data ──────────────────────────────────────────────────────

const _kPolaroidImage =
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=200&h=200&fit=crop';
const _kVinylImage =
    'https://images.unsplash.com/photo-1539375665275-f9de415ef9ac?w=200&h=200&fit=crop';
const _kBagImage =
    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200&h=200&fit=crop';

const _conversation = <_ChatItem>[
  // ── Monday — Polaroid Camera ($45 → $42 agreed → meetup) ──
  _ChatItem(type: _ItemType.dateSeparator, text: 'Monday'),
  _ChatItem(
    text: 'Hey! Loved your latest video',
    timeAgo: '10:30 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Thanks! Took ages to edit',
    timeAgo: '10:32 AM',
    isMine: true,
  ),
  _ChatItem(
    text: 'The transition at 0:15 was so smooth',
    timeAgo: '10:33 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'I used a new plugin for that!',
    timeAgo: '10:35 AM',
    isMine: true,
  ),
  _ChatItem(
    text: 'Nice! btw I saw you liked my Polaroid listing',
    timeAgo: '10:38 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Yeah it looks great! Would you take \$38?',
    timeAgo: '10:40 AM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.offerSent,
    productTitle: 'Polaroid Camera',
    productImageUrl: _kPolaroidImage,
    amount: 38,
    originalPrice: 45,
    timeAgo: '10:40 AM',
    isMine: true,
  ),
  _ChatItem(
    text: "Hmm, could you do \$42? It's in great condition",
    timeAgo: '10:45 AM',
    isMine: false,
  ),
  _ChatItem(
    type: _ItemType.counterOffer,
    productTitle: 'Polaroid Camera',
    productImageUrl: _kPolaroidImage,
    amount: 42,
    originalPrice: 45,
    timeAgo: '10:45 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Deal! \$42 works',
    timeAgo: '10:48 AM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.offerAccepted,
    productTitle: 'Polaroid Camera',
    productImageUrl: _kPolaroidImage,
    amount: 42,
    originalPrice: 45,
    timeAgo: '10:48 AM',
  ),
  _ChatItem(
    text: "Awesome! Meet & Pay? I'm near Blue Bottle",
    timeAgo: '10:52 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Perfect, tomorrow at 2pm?',
    timeAgo: '10:55 AM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.meetupPending,
    productTitle: 'Polaroid Camera',
    statusLabel: 'Meet & Pay',
    detailLine: 'Blue Bottle Coffee',
    timeAgo: 'Tue 2:00 PM',
  ),

  // ── Tuesday — Camera delivered + Vinyl Records ($120 → $100 → shipping) ──
  _ChatItem(type: _ItemType.dateSeparator, text: 'Tuesday'),
  _ChatItem(
    text: 'Just got home, camera works perfectly!',
    timeAgo: '3:30 PM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.purchaseComplete,
    productTitle: 'Polaroid Camera',
    productImageUrl: _kPolaroidImage,
    amount: 42,
    timeAgo: '3:30 PM',
  ),
  _ChatItem(
    text: 'Glad you love it! Interested in my vinyl collection too?',
    timeAgo: '3:35 PM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Oh those records? They look amazing',
    timeAgo: '3:38 PM',
    isMine: true,
  ),
  _ChatItem(
    text: 'Would you do \$95 for the lot?',
    timeAgo: '3:40 PM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.offerSent,
    productTitle: 'Vinyl Records',
    productImageUrl: _kVinylImage,
    amount: 95,
    originalPrice: 120,
    timeAgo: '3:40 PM',
    isMine: true,
  ),
  _ChatItem(
    text: 'Lowest I could do is \$105',
    timeAgo: '3:48 PM',
    isMine: false,
  ),
  _ChatItem(
    type: _ItemType.counterOffer,
    productTitle: 'Vinyl Records',
    productImageUrl: _kVinylImage,
    amount: 105,
    originalPrice: 120,
    timeAgo: '3:48 PM',
    isMine: false,
  ),
  _ChatItem(
    text: '\$100 even and we have a deal?',
    timeAgo: '3:52 PM',
    isMine: true,
  ),
  _ChatItem(
    text: 'OK you got it! Ship or meet up?',
    timeAgo: '3:55 PM',
    isMine: false,
  ),
  _ChatItem(
    type: _ItemType.offerAccepted,
    productTitle: 'Vinyl Records',
    productImageUrl: _kVinylImage,
    amount: 100,
    originalPrice: 120,
    timeAgo: '3:55 PM',
  ),
  _ChatItem(
    text: "Ship it this time, I'll pay shipping",
    timeAgo: '4:00 PM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.shipPending,
    productTitle: 'Vinyl Records',
    statusLabel: 'Standard Shipping',
    detailLine: 'Est. 5-7 days',
    amount: 4.99,
    timeAgo: '4:00 PM',
  ),

  // ── Today — Leather Bag ($89 → $70 offered → pending) ──
  _ChatItem(type: _ItemType.dateSeparator, text: 'Today'),
  _ChatItem(
    text: "Shipped! Here's your tracking",
    timeAgo: '9:15 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Thanks! Also, is that leather bag still available?',
    timeAgo: '9:20 AM',
    isMine: true,
  ),
  _ChatItem(
    text: 'The weekend bag? Yeah! \$89',
    timeAgo: '9:25 AM',
    isMine: false,
  ),
  _ChatItem(
    text: 'Would you take \$70?',
    timeAgo: '9:28 AM',
    isMine: true,
  ),
  _ChatItem(
    type: _ItemType.offerSent,
    productTitle: 'Leather Weekend Bag',
    productImageUrl: _kBagImage,
    amount: 70,
    originalPrice: 89,
    timeAgo: '9:28 AM',
    isMine: true,
  ),
];

// ── Main Screen ─────────────────────────────────────────────────────────────

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          _ChatHeader(theme: theme),
          Expanded(
            child: _TransactionList(
              theme: theme,
              scrollController: _scrollController,
            ),
          ),
          _RichInputBar(theme: theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Transaction List ───────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  final ProtoTheme theme;
  final ScrollController scrollController;

  const _TransactionList({
    required this.theme,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Count total outgoing messages for read receipt logic
    int totalOutgoing = 0;
    for (final item in _conversation) {
      if (item.type == _ItemType.message && item.isMine) totalOutgoing++;
    }

    // Build widget list with running counters
    int outgoingNum = 0;
    int incomingNum = 0;
    final widgets = <Widget>[];

    for (final item in _conversation) {
      if (item.type == _ItemType.message && item.isMine) outgoingNum++;
      if (item.type == _ItemType.message && !item.isMine) incomingNum++;

      switch (item.type) {
        case _ItemType.dateSeparator:
          widgets.add(_DateSeparator(theme: theme, label: item.text!));
          break;
        case _ItemType.message:
          widgets.add(_swipeableChatItem(
            context,
            theme,
            item,
            widgets.length,
            _MessageBubble(
              theme: theme,
              item: item,
              outgoingNum: item.isMine ? outgoingNum : 0,
              incomingNum: !item.isMine ? incomingNum : 0,
              totalOutgoing: totalOutgoing,
            ),
          ));
          break;
        case _ItemType.offerSent:
        case _ItemType.counterOffer:
          widgets.add(_OfferCard(theme: theme, item: item));
          break;
        case _ItemType.offerAccepted:
          widgets.add(_AcceptedCard(theme: theme, item: item));
          break;
        case _ItemType.meetupPending:
        case _ItemType.shipPending:
          widgets.add(_DeliveryCard(theme: theme, item: item));
          break;
        case _ItemType.purchaseComplete:
          widgets.add(_CompletedCard(theme: theme, item: item));
          break;
      }
    }
    widgets.add(_TypingIndicator(theme: theme));

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: widgets,
    );
  }
}

// ── Swipe-to-delete for _ChatItem ───────────────────────────────────────────

Widget _swipeableChatItem(
  BuildContext context,
  ProtoTheme theme,
  _ChatItem item,
  int index,
  Widget child,
) {
  return Dismissible(
    key: ValueKey('chat-msg-$index'),
    direction: item.isMine
        ? DismissDirection.endToStart
        : DismissDirection.startToEnd,
    confirmDismiss: (_) => _showDeleteSheet(context, theme, item),
    background: Container(
      alignment: item.isMine ? Alignment.centerRight : Alignment.centerLeft,
      padding: item.isMine
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
    BuildContext context, ProtoTheme theme, _ChatItem item) async {
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
          if (item.isMine)
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

// ── Chat Header ─────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final ProtoTheme theme;

  const _ChatHeader({
    required this.theme,
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
          // Row 1: Back + More menu
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

// ── Message Bubble with Read Receipts & Reaction ────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ProtoTheme theme;
  final _ChatItem item;
  final int outgoingNum;
  final int incomingNum;
  final int totalOutgoing;

  const _MessageBubble({
    required this.theme,
    required this.item,
    required this.outgoingNum,
    required this.incomingNum,
    required this.totalOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    final showReaction = !item.isMine && incomingNum == 3;

    // Check if this is the last "Read" outgoing message
    bool isLastReadOutgoing = false;
    if (item.isMine && outgoingNum <= totalOutgoing - 2) {
      // Check if the next outgoing would exceed the read threshold
      isLastReadOutgoing = outgoingNum == totalOutgoing - 2;
    }

    return Column(
      crossAxisAlignment:
          item.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment:
              item.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => _showReactionPicker(context),
            onDoubleTap: () {
              final preview = item.text!.length > 25
                  ? '${item.text!.substring(0, 25)}...'
                  : item.text!;
              ProtoToast.show(
                context,
                Icons.reply_rounded,
                'Reply to "$preview"',
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: showReaction ? 2 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 240),
              decoration: BoxDecoration(
                color: item.isMine ? theme.primary : theme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight:
                      item.isMine ? const Radius.circular(4) : null,
                  bottomLeft:
                      !item.isMine ? const Radius.circular(4) : null,
                ),
                boxShadow: item.isMine ? null : theme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.text!,
                    style: TextStyle(
                      fontSize: 14,
                      color: item.isMine ? Colors.white : theme.text,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.timeAgo,
                        style: TextStyle(
                          fontSize: 10,
                          color: item.isMine
                              ? Colors.white.withValues(alpha: 0.6)
                              : theme.textTertiary,
                        ),
                      ),
                      if (item.isMine) ...[
                        const SizedBox(width: 3),
                        _readReceiptIcon(),
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
              'Seen 4:02 PM',
              style: TextStyle(fontSize: 10, color: theme.textTertiary),
            ),
          ),
      ],
    );
  }

  Widget _readReceiptIcon() {
    if (outgoingNum <= totalOutgoing - 2) {
      // Read — light blue double check
      return const Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Color(0xFF4FC3F7),
      );
    } else if (outgoingNum == totalOutgoing - 1) {
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

// ── Date Separator ──────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  const _DateSeparator({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.textTertiary.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.caption.copyWith(
                color: theme.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.textTertiary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Offer Card (offerSent + counterOffer) ───────────────────────────────────

class _OfferCard extends StatelessWidget {
  final ProtoTheme theme;
  final _ChatItem item;
  const _OfferCard({required this.theme, required this.item});

  bool get _isCounter => item.type == _ItemType.counterOffer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product row
          Row(
            children: [
              ProtoNetworkImage(
                imageUrl: item.productImageUrl!,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productTitle!,
                        style: theme.title.copyWith(fontSize: 13)),
                    Text(
                      'Listed: \$${item.originalPrice!.toStringAsFixed(0)}',
                      style: theme.caption.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: theme.textTertiary.withValues(alpha: 0.15),
            height: 20,
          ),
          // Offer line
          Row(
            children: [
              Icon(Icons.local_offer_rounded,
                  size: 16, color: theme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _isCounter
                      ? 'Maya counter-offered \$${item.amount!.toStringAsFixed(0)}'
                      : 'You offered \$${item.amount!.toStringAsFixed(0)}',
                  style: theme.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _outlinedButton(
                  context,
                  _isCounter ? 'Accept' : 'Change Offer',
                  _isCounter ? Icons.check_rounded : Icons.edit_rounded,
                  _isCounter ? 'Offer accepted' : 'Change offer',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _outlinedButton(
                  context,
                  _isCounter ? 'Counter' : 'Withdraw',
                  _isCounter ? Icons.reply_rounded : Icons.close_rounded,
                  _isCounter ? 'Counter-offer sent' : 'Offer withdrawn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton(
    BuildContext context,
    String label,
    IconData icon,
    String toast,
  ) {
    return ProtoPressButton(
      onTap: () => ProtoToast.show(context, icon, toast),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Accepted Card ───────────────────────────────────────────────────────────

class _AcceptedCard extends StatelessWidget {
  final ProtoTheme theme;
  final _ChatItem item;
  const _AcceptedCard({required this.theme, required this.item});

  static const _green = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: _green),
              const SizedBox(width: 6),
              Text(
                'Price Agreed!',
                style: theme.title.copyWith(fontSize: 14, color: _green),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Product row
          Row(
            children: [
              ProtoNetworkImage(
                imageUrl: item.productImageUrl!,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productTitle!,
                        style: theme.title.copyWith(fontSize: 13)),
                    Row(
                      children: [
                        Text(
                          'Agreed: \$${item.amount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(was \$${item.originalPrice!.toStringAsFixed(0)})',
                          style: theme.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Button
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              Icons.local_shipping_rounded,
              'Choose delivery method',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _green.withValues(alpha: 0.4)),
              ),
              child: const Center(
                child: Text(
                  'Choose Delivery Method',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery Card (meetupPending + shipPending) ─────────────────────────────

class _DeliveryCard extends StatelessWidget {
  final ProtoTheme theme;
  final _ChatItem item;
  const _DeliveryCard({required this.theme, required this.item});

  bool get _isMeetup => item.type == _ItemType.meetupPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _isMeetup
                    ? Icons.handshake_rounded
                    : Icons.local_shipping_rounded,
                size: 18,
                color: theme.tertiary,
              ),
              const SizedBox(width: 6),
              Text(
                _isMeetup ? 'Meet & Pay' : 'Ship It',
                style:
                    theme.title.copyWith(fontSize: 14, color: theme.tertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Detail rows
          if (_isMeetup) ...[
            _detailRow(Icons.location_on_rounded, item.detailLine!),
            const SizedBox(height: 6),
            _detailRow(Icons.calendar_today_rounded, item.timeAgo),
          ] else ...[
            _detailRow(Icons.inventory_2_rounded, item.statusLabel!),
            const SizedBox(height: 6),
            _detailRow(
              Icons.schedule_rounded,
              '${item.detailLine!} \u00B7 \$${item.amount!.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 10),
          // Action button
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              _isMeetup ? Icons.map_rounded : Icons.local_shipping_rounded,
              _isMeetup ? 'View on Map' : 'Track Shipment',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.tertiary.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: Text(
                  _isMeetup ? 'View on Map' : 'Track Shipment',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.tertiary,
                  ),
                ),
              ),
            ),
          ),
          // Safety tip for meetup
          if (_isMeetup) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield_rounded,
                    size: 14, color: theme.textTertiary),
                const SizedBox(width: 5),
                Text(
                  'Meet in a public place',
                  style: theme.caption.copyWith(
                    color: theme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: theme.body.copyWith(fontSize: 13)),
      ],
    );
  }
}

// ── Completed Card ──────────────────────────────────────────────────────────

class _CompletedCard extends StatelessWidget {
  final ProtoTheme theme;
  final _ChatItem item;
  const _CompletedCard({required this.theme, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 18, color: theme.primary),
              const SizedBox(width: 6),
              Text(
                'Purchase Complete!',
                style:
                    theme.title.copyWith(fontSize: 14, color: theme.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Product row
          Row(
            children: [
              ProtoNetworkImage(
                imageUrl: item.productImageUrl!,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productTitle!,
                      style: theme.title.copyWith(fontSize: 13)),
                  Text(
                    'Paid: \$${item.amount!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Star rating (4 out of 5)
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < 4
                    ? theme.icons.starFilled
                    : Icons.star_outline_rounded,
                size: 18,
                color: i < 4 ? theme.tertiary : theme.textTertiary,
              );
            }),
          ),
          const SizedBox(height: 10),
          // Leave a Review button (filled primary)
          ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              theme.icons.starFilled,
              'Leave a review',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Leave a Review',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
