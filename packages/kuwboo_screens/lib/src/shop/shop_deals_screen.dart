import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Promoted/deal items — product grid with "Deal" badges and claim functionality
class ShopDealsScreen extends StatefulWidget {
  const ShopDealsScreen({super.key});

  static const _deals = [
    _DealItem('Vintage Camera', 45.00, 89.00, 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400&h=400&fit=crop', '49% off'),
    _DealItem('Wireless Earbuds', 29.00, 59.00, 'https://images.unsplash.com/photo-1590658268037-6bf12f032f55?w=400&h=400&fit=crop', '51% off'),
    _DealItem('Leather Jacket', 75.00, 150.00, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&h=400&fit=crop', '50% off'),
    _DealItem('Sneakers', 55.00, 120.00, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop', '54% off'),
    _DealItem('Watch', 85.00, 199.00, 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&h=400&fit=crop', '57% off'),
    _DealItem('Sunglasses', 25.00, 65.00, 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=400&fit=crop', '62% off'),
  ];

  @override
  State<ShopDealsScreen> createState() => _ShopDealsScreenState();
}

class _ShopDealsScreenState extends State<ShopDealsScreen> {
  final Set<int> _savedDeals = {};

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Deals', style: theme.headline.copyWith(fontSize: 24)),
                const SizedBox(width: 8),
                Icon(theme.icons.localFireDepartment, size: 22, color: theme.accent),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Limited time offers near you', style: theme.body.copyWith(color: theme.textSecondary)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: ShopDealsScreen._deals.length,
              itemBuilder: (context, i) {
                final deal = ShopDealsScreen._deals[i];
                final isSaved = _savedDeals.contains(i);
                return ProtoPressButton(
                  onTap: () => state.push(ProtoRoutes.shopProduct),
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
                                ProtoNetworkImage(imageUrl: deal.imageUrl),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(deal.discount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ),
                                ),
                                // Save/bookmark button
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        if (isSaved) {
                                          _savedDeals.remove(i);
                                        } else {
                                          _savedDeals.add(i);
                                        }
                                      });
                                      ProtoToast.show(
                                        context,
                                        isSaved ? theme.icons.bookmarkOutline : theme.icons.bookmarkFilled,
                                        isSaved ? 'Deal unsaved' : 'Deal saved!',
                                      );
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isSaved ? theme.icons.bookmarkFilled : theme.icons.bookmarkOutline,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deal.title, style: theme.title.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      '\$${deal.salePrice.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.accent, fontFamily: theme.displayFont),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '\$${deal.originalPrice.toStringAsFixed(0)}',
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
            ),
          ),
        ],
      );
  }
}

class _DealItem {
  final String title;
  final double salePrice;
  final double originalPrice;
  final String imageUrl;
  final String discount;
  const _DealItem(this.title, this.salePrice, this.originalPrice, this.imageUrl, this.discount);
}
