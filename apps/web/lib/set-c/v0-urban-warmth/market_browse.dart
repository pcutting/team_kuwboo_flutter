import 'package:flutter/material.dart';
import '../../v0-urban-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V0: Urban Warmth Marketplace Browse (Set C - Service Switcher FAB)
/// Warm search bar, organic pill chips, terracotta product cards with soft shadows

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UrbanWarmthTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: UrbanWarmthTheme.background,
                  accentColor: UrbanWarmthTheme.primary,
                  textColor: UrbanWarmthTheme.text,
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UrbanWarmthTheme.spacingMd,
                  ),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: UrbanWarmthTheme.spacingSm),
                // Category chips — organic pills
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UrbanWarmthTheme.spacingMd,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: UrbanWarmthTheme.spacingMd,
                          vertical: UrbanWarmthTheme.spacingSm,
                        ),
                        decoration: isSelected
                            ? UrbanWarmthTheme.accentPillDecoration(UrbanWarmthTheme.primary)
                            : UrbanWarmthTheme.pillDecoration,
                        child: Text(
                          _categories[index],
                          style: UrbanWarmthTheme.caption.copyWith(
                            color: isSelected
                                ? UrbanWarmthTheme.primary
                                : UrbanWarmthTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: UrbanWarmthTheme.spacingMd),
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UrbanWarmthTheme.spacingMd,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'TRENDING NOW',
                        style: UrbanWarmthTheme.label.copyWith(
                          color: UrbanWarmthTheme.textTertiary,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'See all',
                        style: UrbanWarmthTheme.caption.copyWith(
                          color: UrbanWarmthTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UrbanWarmthTheme.spacingSm),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UrbanWarmthTheme.spacingMd,
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
        color: UrbanWarmthTheme.surface,
        borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
        boxShadow: UrbanWarmthTheme.softShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: UrbanWarmthTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search marketplace...',
              style: UrbanWarmthTheme.body.copyWith(
                fontSize: 13,
                color: UrbanWarmthTheme.textTertiary,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: UrbanWarmthTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 14,
              color: UrbanWarmthTheme.primary,
            ),
          ),
          const SizedBox(width: 8),
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
      decoration: UrbanWarmthTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: UrbanWarmthTheme.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 32,
                      color: UrbanWarmthTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UrbanWarmthTheme.spacingSm,
                vertical: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: UrbanWarmthTheme.title.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: UrbanWarmthTheme.title.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: UrbanWarmthTheme.primary,
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
                          color: UrbanWarmthTheme.secondary.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            product.seller[0],
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.seller,
                          style: UrbanWarmthTheme.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: UrbanWarmthTheme.pillDecoration,
                        child: Text(
                          product.condition,
                          style: UrbanWarmthTheme.caption.copyWith(fontSize: 8),
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
      backgroundColor: UrbanWarmthTheme.surface,
      activeColor: UrbanWarmthTheme.primary,
      inactiveColor: UrbanWarmthTheme.textSecondary,
      fabColor: UrbanWarmthTheme.secondary,
      fabIconColor: UrbanWarmthTheme.surface,
      borderColor: UrbanWarmthTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: UrbanWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}
