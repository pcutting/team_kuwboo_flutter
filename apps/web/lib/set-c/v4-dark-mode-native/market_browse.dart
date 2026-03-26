import 'package:flutter/material.dart';
import '../../v4-dark-mode-native/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V4: Dark Mode Native Marketplace Browse (Set C - Service Switcher FAB)
/// OLED-optimized product grid with neon accents and elevated dark cards

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = [
    'All',
    'Vintage',
    'Handmade',
    'Fashion',
    'Tech',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DarkModeNativeTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: DarkModeNativeTheme.background,
                  accentColor: DarkModeNativeTheme.primary,
                  textColor: DarkModeNativeTheme.text,
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DarkModeNativeTheme.spacingMd,
                  ),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: DarkModeNativeTheme.spacingSm),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DarkModeNativeTheme.spacingMd,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: isSelected
                            ? DarkModeNativeTheme.primaryButtonDecoration(
                                DarkModeNativeTheme.primary,
                              )
                            : DarkModeNativeTheme.outlineButtonDecoration,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DarkModeNativeTheme.spacingMd,
                            vertical: DarkModeNativeTheme.spacingSm,
                          ),
                          child: Text(
                            _categories[index],
                            style: DarkModeNativeTheme.caption.copyWith(
                              color: isSelected
                                  ? DarkModeNativeTheme.text
                                  : DarkModeNativeTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: DarkModeNativeTheme.spacingMd),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DarkModeNativeTheme.spacingMd,
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
      height: 42,
      decoration: BoxDecoration(
        color: DarkModeNativeTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusMd),
        border: Border.all(color: DarkModeNativeTheme.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: DarkModeNativeTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search marketplace...',
              style: DarkModeNativeTheme.body.copyWith(
                fontSize: 13,
                color: DarkModeNativeTheme.textTertiary,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: DarkModeNativeTheme.border,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.tune_rounded,
            size: 18,
            color: DarkModeNativeTheme.primary,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = DemoDataExtended.products;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(DemoProduct product) {
    return Container(
      decoration: DarkModeNativeTheme.elevatedCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: DarkModeNativeTheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 32,
                        color: DarkModeNativeTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                // Condition badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: DarkModeNativeTheme.surfaceElevated
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(
                        DarkModeNativeTheme.radiusSm,
                      ),
                      border: Border.all(
                        color: DarkModeNativeTheme.border,
                      ),
                    ),
                    child: Text(
                      product.condition,
                      style: DarkModeNativeTheme.caption.copyWith(
                        fontSize: 8,
                        color: DarkModeNativeTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(DarkModeNativeTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: DarkModeNativeTheme.title.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Price in secondary (cyan) color
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: DarkModeNativeTheme.title.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DarkModeNativeTheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  // Seller info row
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DarkModeNativeTheme.primary
                              .withValues(alpha: 0.2),
                          border: Border.all(
                            color: DarkModeNativeTheme.primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            product.seller[0],
                            style: DarkModeNativeTheme.caption.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: DarkModeNativeTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.seller,
                          style: DarkModeNativeTheme.caption.copyWith(
                            fontSize: 10,
                            color: DarkModeNativeTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
      backgroundColor: DarkModeNativeTheme.surfaceElevated,
      activeColor: DarkModeNativeTheme.primary,
      inactiveColor: DarkModeNativeTheme.textTertiary,
      fabColor: DarkModeNativeTheme.secondary,
      fabIconColor: DarkModeNativeTheme.background,
      borderColor: DarkModeNativeTheme.border,
      height: 52,
      fabSize: 50,
      labelStyle: DarkModeNativeTheme.caption.copyWith(fontSize: 8),
    );
  }
}
