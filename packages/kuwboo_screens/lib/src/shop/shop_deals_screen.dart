import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'shop_format.dart';
import 'shop_providers.dart';

/// Promoted/deal items — product grid with discount badges.
class ShopDealsScreen extends ConsumerStatefulWidget {
  const ShopDealsScreen({super.key});

  @override
  ConsumerState<ShopDealsScreen> createState() => _ShopDealsScreenState();
}

class _ShopDealsScreenState extends ConsumerState<ShopDealsScreen> {
  final Set<String> _savedIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final async = ref.watch(shopDealsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('Deals', style: theme.headline.copyWith(fontSize: 24)),
              const SizedBox(width: 8),
              Icon(
                theme.icons.localFireDepartment,
                size: 22,
                color: theme.accent,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Limited time offers near you',
            style: theme.body.copyWith(color: theme.textSecondary),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ProtoErrorState(
              message: 'Could not load deals',
              onRetry: () => ref.invalidate(shopDealsProvider),
            ),
            data: (page) {
              final deals = page.items;
              if (deals.isEmpty) {
                return const ProtoEmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'No active deals',
                  subtitle: 'Check back soon for limited-time offers',
                );
              }
              return _DealsGrid(
                deals: deals,
                theme: theme,
                savedIds: _savedIds,
                onToggleSave: (id, wasSaved) {
                  setState(() {
                    if (wasSaved) {
                      _savedIds.remove(id);
                    } else {
                      _savedIds.add(id);
                    }
                  });
                  ProtoToast.show(
                    context,
                    wasSaved
                        ? theme.icons.bookmarkOutline
                        : theme.icons.bookmarkFilled,
                    wasSaved ? 'Deal unsaved' : 'Deal saved!',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DealsGrid extends StatelessWidget {
  const _DealsGrid({
    required this.deals,
    required this.theme,
    required this.savedIds,
    required this.onToggleSave,
  });

  final List<Product> deals;
  final ProtoTheme theme;
  final Set<String> savedIds;
  final void Function(String id, bool wasSaved) onToggleSave;

  String _discountLabel(Product p) {
    final original = p.originalPriceCents;
    if (original == null || original <= 0) return '';
    final pct = ((original - p.priceCents) / original * 100).round();
    return pct > 0 ? '$pct% off' : '';
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: deals.length,
      itemBuilder: (context, i) {
        final deal = deals[i];
        final isSaved = savedIds.contains(deal.id);
        final discount = _discountLabel(deal);
        return ProtoPressButton(
          onTap: () => state.pushWithArgs(
            ProtoRoutes.shopProduct,
            {'productId': deal.id},
          ),
          child: Container(
            decoration: theme.cardDecoration,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProtoNetworkImage(
                        imageUrl: deal.thumbnailUrl ??
                            'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400&h=400&fit=crop',
                      ),
                      if (discount.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              discount,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onToggleSave(deal.id, isSaved),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? theme.icons.bookmarkFilled
                                  : theme.icons.bookmarkOutline,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.title,
                          style: theme.title.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              formatPriceCents(deal.priceCents, deal.currency),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.accent,
                                fontFamily: theme.displayFont,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (deal.originalPriceCents != null)
                              Text(
                                formatPriceCents(
                                  deal.originalPriceCents,
                                  deal.currency,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
