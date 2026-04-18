import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'shop_format.dart';
import 'shop_providers.dart';

class ShopAuctionDetail extends ConsumerStatefulWidget {
  /// Auction identifier. Route builders pass this via
  /// `extra: {'auctionId': ...}`.
  final String? auctionId;

  const ShopAuctionDetail({super.key, this.auctionId});

  @override
  ConsumerState<ShopAuctionDetail> createState() => _ShopAuctionDetailState();
}

class _ShopAuctionDetailState extends ConsumerState<ShopAuctionDetail> {
  Timer? _tickTimer;
  int _bidIncrementCents = 500; // default +£5

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown(DateTime endsAt) {
    final remaining = endsAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Auction ended';
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    return '${h}h ${m}m ${s}s remaining';
  }

  Future<void> _handlePlaceBid(AuctionWithBids awb) async {
    final auction = awb.auction;
    final bidCents = auction.currentPriceCents + _bidIncrementCents;
    final formatted = formatPriceCents(bidCents, 'GBP');
    final confirmed = await ProtoConfirmDialog.show(
      context,
      title: 'Place Bid',
      message: 'Bid $formatted on this auction?',
    );
    if (!mounted || !confirmed) return;
    final theme = ProtoTheme.of(context);
    final id = widget.auctionId;
    if (id == null) return;
    try {
      await ref
          .read(marketplaceApiProvider)
          .placeBid(auctionId: id, amountCents: bidCents);
      if (!mounted) return;
      ref.invalidate(auctionDetailProvider(id));
      ProtoToast.show(context, theme.icons.gavel, 'Bid placed: $formatted');
    } catch (_) {
      if (!mounted) return;
      ProtoToast.show(context, Icons.error_outline, 'Could not place bid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final id = widget.auctionId;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(
              title: 'Auction',
              actions: [
                ProtoPressButton(
                  onTap: () => ProtoShareSheet.show(context),
                  child: Icon(theme.icons.share, size: 20, color: theme.text),
                ),
              ],
            ),
            Expanded(
              child: id == null
                  ? const ProtoEmptyState(
                      icon: Icons.gavel_rounded,
                      title: 'No auction selected',
                      subtitle: 'Open an auction from a listing',
                    )
                  : ref
                        .watch(auctionDetailProvider(id))
                        .when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => ProtoErrorState(
                            message: 'Could not load auction',
                            onRetry: () =>
                                ref.invalidate(auctionDetailProvider(id)),
                          ),
                          data: (awb) => _AuctionBody(
                            awb: awb,
                            theme: theme,
                            bidIncrementCents: _bidIncrementCents,
                            onChangeIncrement: (v) =>
                                setState(() => _bidIncrementCents = v),
                            countdownText: _formatCountdown(awb.auction.endsAt),
                          ),
                        ),
            ),
            if (id != null)
              _PlaceBidBar(
                theme: theme,
                onTap: () {
                  final awb = ref.read(auctionDetailProvider(id)).valueOrNull;
                  if (awb != null) _handlePlaceBid(awb);
                },
                nextBidLabel: _nextBidLabel(id),
              ),
          ],
        ),
      ),
    );
  }

  String _nextBidLabel(String id) {
    final awb = ref.watch(auctionDetailProvider(id)).valueOrNull;
    if (awb == null) return 'Place Bid';
    final nextCents = awb.auction.currentPriceCents + _bidIncrementCents;
    return 'Place Bid  ${formatPriceCents(nextCents, 'GBP')}';
  }
}

class _AuctionBody extends StatelessWidget {
  const _AuctionBody({
    required this.awb,
    required this.theme,
    required this.bidIncrementCents,
    required this.onChangeIncrement,
    required this.countdownText,
  });

  final AuctionWithBids awb;
  final ProtoTheme theme;
  final int bidIncrementCents;
  final ValueChanged<int> onChangeIncrement;
  final String countdownText;

  @override
  Widget build(BuildContext context) {
    final auction = awb.auction;
    final idShort = auction.id.substring(0, auction.id.length.clamp(0, 6));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(theme.radiusMd),
          ),
          child: Center(
            child: Icon(
              theme.icons.gavel,
              size: 48,
              color: theme.primary.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Auction #$idShort', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(theme.icons.timerFilled, size: 18, color: theme.accent),
              const SizedBox(width: 8),
              Text(
                countdownText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Current Bid', style: theme.body),
            const Spacer(),
            Text(
              formatPriceCents(auction.currentPriceCents, 'GBP'),
              style: theme.headline.copyWith(
                color: theme.primary,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Your bid:', style: theme.body),
            const Spacer(),
            for (final incCents in const [500, 1000, 2500]) ...[
              ProtoPressButton(
                duration: const Duration(milliseconds: 100),
                onTap: () => onChangeIncrement(incCents),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: bidIncrementCents == incCents
                        ? theme.primary
                        : theme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bidIncrementCents == incCents
                          ? theme.primary
                          : theme.text.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '+${formatPriceCents(incCents, 'GBP')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: bidIncrementCents == incCents
                          ? Colors.white
                          : theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text('Bid History', style: theme.title),
        const SizedBox(height: 8),
        if (awb.bids.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No bids yet', style: theme.caption),
          )
        else
          ...awb.bids.map((bid) {
            final bidderInitial = bid.bidderId.isNotEmpty
                ? bid.bidderId[0].toUpperCase()
                : '?';
            final bidderShort = bid.bidderId.substring(
              0,
              bid.bidderId.length.clamp(0, 6),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.primary.withValues(alpha: 0.1),
                    child: Text(
                      bidderInitial,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bidder $bidderShort',
                      style: theme.body.copyWith(color: theme.text),
                    ),
                  ),
                  Text(
                    formatPriceCents(bid.amountCents, 'GBP'),
                    style: theme.title.copyWith(fontSize: 14),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _PlaceBidBar extends StatelessWidget {
  const _PlaceBidBar({
    required this.theme,
    required this.onTap,
    required this.nextBidLabel,
  });

  final ProtoTheme theme;
  final VoidCallback onTap;
  final String nextBidLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: ProtoPressButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              nextBidLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
