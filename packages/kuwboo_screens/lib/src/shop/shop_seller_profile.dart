import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'shop_providers.dart';

class ShopSellerProfile extends ConsumerStatefulWidget {
  /// Seller (user) identifier. Route builders pass this via
  /// `extra: {'sellerId': ...}`.
  final String? sellerId;

  const ShopSellerProfile({super.key, this.sellerId});

  @override
  ConsumerState<ShopSellerProfile> createState() => _ShopSellerProfileState();
}

class _ShopSellerProfileState extends ConsumerState<ShopSellerProfile> {
  String _activeTab = 'Reviews';
  bool _isFriend = false;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final id = widget.sellerId;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(
              title: 'Seller',
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
                      icon: Icons.person_outline_rounded,
                      title: 'No seller selected',
                      subtitle: 'Open a seller from a product listing',
                    )
                  : ref
                        .watch(sellerRatingsProvider(id))
                        .when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => ProtoErrorState(
                            message: 'Could not load seller',
                            onRetry: () =>
                                ref.invalidate(sellerRatingsProvider(id)),
                          ),
                          data: (page) => _SellerBody(
                            sellerId: id,
                            page: page,
                            theme: theme,
                            activeTab: _activeTab,
                            onTabChanged: (tab) =>
                                setState(() => _activeTab = tab),
                            isFriend: _isFriend,
                            onToggleFriend: () {
                              setState(() => _isFriend = !_isFriend);
                              ProtoToast.show(
                                context,
                                _isFriend
                                    ? theme.icons.personAdd
                                    : theme.icons.personRemove,
                                _isFriend
                                    ? 'Friend request sent'
                                    : 'Friend removed',
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerBody extends StatelessWidget {
  const _SellerBody({
    required this.sellerId,
    required this.page,
    required this.theme,
    required this.activeTab,
    required this.onTabChanged,
    required this.isFriend,
    required this.onToggleFriend,
  });

  final String sellerId;
  final SellerRatingPage page;
  final ProtoTheme theme;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final bool isFriend;
  final VoidCallback onToggleFriend;

  String _sellerShortId() => sellerId.substring(0, sellerId.length.clamp(0, 6));

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final avg = page.averageRating;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const ProtoAvatar(
                radius: 40,
                imageUrl:
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
              ),
              const SizedBox(height: 10),
              Text(
                'Seller ${_sellerShortId()}',
                style: theme.headline.copyWith(fontSize: 22),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(theme.icons.starFilled, size: 18, color: theme.tertiary),
                  Text(
                    ' ${avg.toStringAsFixed(1)}',
                    style: theme.title.copyWith(fontSize: 14),
                  ),
                  Text(' (${page.items.length} reviews)', style: theme.caption),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProtoPressButton(
                    onTap: onToggleFriend,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isFriend ? theme.secondary : theme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            theme.icons.personAdd,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFriend ? 'Friends' : 'Add Friend',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ProtoPressButton(
                    onTap: () => state.push(ProtoRoutes.chatConversation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.text.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(count: page.items.length.toString(), label: 'Reviews'),
            _Stat(count: avg.toStringAsFixed(1), label: 'Rating'),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ['Reviews', 'About'].map((tab) {
              final isActive = tab == activeTab;
              return Expanded(
                child: ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => onTabChanged(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? theme.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isActive ? theme.softShadow : null,
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive ? theme.text : theme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (activeTab == 'Reviews')
          _ReviewsList(page: page, theme: theme)
        else
          _AboutBlock(sellerId: sellerId, theme: theme),
      ],
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({required this.page, required this.theme});

  final SellerRatingPage page;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    final reviews = page.items;
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Text('No reviews yet', style: theme.body),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: theme.cardDecoration,
          child: Row(
            children: [
              Text(
                page.averageRating.toStringAsFixed(1),
                style: theme.headline.copyWith(fontSize: 36),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < page.averageRating.round();
                      return Icon(
                        filled
                            ? theme.icons.starFilled
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: theme.tertiary,
                      );
                    }),
                  ),
                  const SizedBox(height: 2),
                  Text('${reviews.length} reviews', style: theme.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...reviews.map((r) {
          final buyerShort = r.buyerId.substring(
            0,
            r.buyerId.length.clamp(0, 6),
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: theme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Buyer $buyerShort',
                      style: theme.title.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    ...List.generate(5, (i) {
                      return Icon(
                        i < r.rating
                            ? theme.icons.starFilled
                            : Icons.star_outline_rounded,
                        size: 12,
                        color: i < r.rating
                            ? theme.tertiary
                            : theme.textTertiary,
                      );
                    }),
                  ],
                ),
                if (r.review != null) ...[
                  const SizedBox(height: 6),
                  Text(r.review!, style: theme.body),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.sellerId, required this.theme});

  final String sellerId;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: theme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this seller', style: theme.title),
          const SizedBox(height: 6),
          Text('Seller ID: $sellerId', style: theme.caption),
        ],
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
    final theme = ProtoTheme.of(context);
    return Column(
      children: [
        Text(count, style: theme.title.copyWith(fontSize: 18)),
        Text(label, style: theme.caption),
      ],
    );
  }
}
