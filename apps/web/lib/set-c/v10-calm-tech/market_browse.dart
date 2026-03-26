import 'package:flutter/material.dart';
import '../../v10-calm-tech/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V10: Calm Tech Marketplace Browse (Set C - Service Switcher FAB)
/// Gentle browsing — soft cards, no pressure to buy

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CalmTechTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: CalmTechTheme.background,
                  accentColor: CalmTechTheme.primary,
                  textColor: CalmTechTheme.text,
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalmTechTheme.spacingLg,
                  ),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: CalmTechTheme.spacingSm),
                // Categories
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmTechTheme.spacingLg,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      final colors = [
                        CalmTechTheme.primary,
                        CalmTechTheme.secondary,
                        CalmTechTheme.tertiary,
                        CalmTechTheme.primary,
                        CalmTechTheme.secondary,
                      ];
                      final color = colors[index % colors.length];

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: CalmTechTheme.spacingMd,
                          vertical: CalmTechTheme.spacingSm,
                        ),
                        decoration: isSelected
                            ? CalmTechTheme.primaryButtonDecoration(color)
                            : CalmTechTheme.pillDecoration(color),
                        child: Text(
                          _categories[index],
                          style: CalmTechTheme.caption.copyWith(
                            color: isSelected
                                ? CalmTechTheme.surface
                                : color,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: CalmTechTheme.spacingMd),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmTechTheme.spacingLg,
                    ),
                    child: _buildProductGrid(),
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: CalmTechTheme.softCardDecoration,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: CalmTechTheme.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Find something nice...',
              style: CalmTechTheme.body.copyWith(
                fontSize: 14,
                color: CalmTechTheme.textTertiary,
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: CalmTechTheme.pillDecoration(CalmTechTheme.primary),
            child: Icon(
              Icons.tune_rounded,
              size: 16,
              color: CalmTechTheme.primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = DemoDataExtended.products;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final colors = [
          CalmTechTheme.primary,
          CalmTechTheme.secondary,
          CalmTechTheme.tertiary,
          CalmTechTheme.primary,
        ];
        return _buildProductCard(
          products[index],
          colors[index % colors.length],
        );
      },
    );
  }

  Widget _buildProductCard(DemoProduct product, Color accent) {
    return Container(
      decoration: CalmTechTheme.softCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
              ),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 32,
                    color: accent.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmTechTheme.spacingSm, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: CalmTechTheme.title.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmTechTheme.spacingSm,
                      vertical: 2,
                    ),
                    decoration: CalmTechTheme.pillDecoration(accent),
                    child: Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: CalmTechTheme.title.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            product.seller[0],
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.seller,
                        style: CalmTechTheme.caption.copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      Text(
                        product.condition,
                        style: CalmTechTheme.caption.copyWith(
                          fontSize: 9,
                          color: accent,
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
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.market,
      backgroundColor: CalmTechTheme.surface,
      activeColor: CalmTechTheme.primary,
      inactiveColor: CalmTechTheme.textSecondary,
      fabColor: CalmTechTheme.primary,
      fabIconColor: CalmTechTheme.surface,
      borderColor: CalmTechTheme.primary.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: CalmTechTheme.caption.copyWith(fontSize: 8),
    );
  }
}
