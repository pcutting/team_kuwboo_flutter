import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Auction detail view with countdown timer, bid history, and bid input.
class AuctionDetailScreen extends StatefulWidget {
  const AuctionDetailScreen({required this.auctionId, super.key});

  final String auctionId;

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidController = TextEditingController();
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _isPlacingBid = false;

  // Demo auction for UI scaffolding.
  late final Auction _auction = Auction(
    id: widget.auctionId,
    productId: 'prod_demo',
    startPriceCents: 1000,
    currentPriceCents: 3250,
    minIncrementCents: 100,
    startsAt: DateTime.now().subtract(const Duration(hours: 12)),
    endsAt: DateTime.now().add(const Duration(hours: 4, minutes: 23)),
    status: 'ACTIVE',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  static const _demoBids = [
    {'user': 'buyer_3', 'amount': 3250, 'time': '2 min ago'},
    {'user': 'buyer_1', 'amount': 2800, 'time': '15 min ago'},
    {'user': 'buyer_2', 'amount': 2200, 'time': '1 hr ago'},
    {'user': 'buyer_1', 'amount': 1800, 'time': '3 hr ago'},
    {'user': 'buyer_3', 'amount': 1200, 'time': '6 hr ago'},
    {'user': 'buyer_2', 'amount': 1000, 'time': '12 hr ago'},
  ];

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = _auction.endsAt.difference(now);
    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bidController.dispose();
    super.dispose();
  }

  String _formatPrice(int cents) {
    final pounds = cents / 100;
    return '\u00a3${pounds.toStringAsFixed(2)}';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _placeBid() async {
    final text = _bidController.text.trim();
    if (text.isEmpty) return;

    final amountPounds = double.tryParse(text);
    if (amountPounds == null || amountPounds <= 0) {
      _showError('Enter a valid amount');
      return;
    }

    final amountCents = (amountPounds * 100).round();
    final minBid = _auction.currentPriceCents + _auction.minIncrementCents;

    if (amountCents < minBid) {
      _showError(
        'Minimum bid is ${_formatPrice(minBid)}',
      );
      return;
    }

    setState(() => _isPlacingBid = true);

    // TODO: call MarketplaceApi.placeBid()
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isPlacingBid = false);
    _bidController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bid of ${_formatPrice(amountCents)} placed')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minBid = _auction.currentPriceCents + _auction.minIncrementCents;

    return Scaffold(
      appBar: AppBar(title: const Text('Auction')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Product image placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.gavel,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Current bid
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Current Bid',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(_auction.currentPriceCents),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_demoBids.length} bids',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Countdown
                Card(
                  color: _remaining == Duration.zero
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: _remaining == Duration.zero
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _remaining == Duration.zero
                              ? 'Auction Ended'
                              : 'Ends in ${_formatDuration(_remaining)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _remaining == Duration.zero
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bid history
                Text(
                  'Bid History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final bid in _demoBids)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          theme.colorScheme.secondaryContainer,
                      child: const Icon(Icons.person, size: 16),
                    ),
                    title: Text(bid['user'] as String),
                    subtitle: Text(bid['time'] as String),
                    trailing: Text(
                      _formatPrice(bid['amount'] as int),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bid input
          if (_remaining > Duration.zero)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bidController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Min ${_formatPrice(minBid)}',
                          prefixText: '\u00a3 ',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _isPlacingBid ? null : _placeBid,
                      child: _isPlacingBid
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Place Bid'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
