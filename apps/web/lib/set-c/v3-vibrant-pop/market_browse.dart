import 'package:flutter/material.dart';
import '../../v3-vibrant-pop/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V3: Vibrant Pop Marketplace Browse (Set C - Service Switcher FAB)
/// Bold search bar, colorful category chips, vibrant 2-column product grid

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
      color: VibrantPopTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: VibrantPopTheme.background,
                  accentColor: VibrantPopTheme.primary,
                  textColor: VibrantPopTheme.text,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: VibrantPopTheme.spacingMd),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: VibrantPopTheme.spacingSm),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: VibrantPopTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return _buildCategoryChip(
                          _categories[index], isSelected);
                    },
                  ),
                ),
                const SizedBox(height: VibrantPopTheme.spacingMd),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VibrantPopTheme.spacingMd),
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
      height: 48,
      decoration: BoxDecoration(
        color: VibrantPopTheme.surface,
        borderRadius:
            BorderRadius.circular(VibrantPopTheme.radiusFull),
        boxShadow: VibrantPopTheme.softShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded,
              size: 22, color: VibrantPopTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search marketplace...',
              style: VibrantPopTheme.body.copyWith(
                color: VibrantPopTheme.textSecondary,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: VibrantPopTheme.primaryGradient,
              borderRadius:
                  BorderRadius.circular(VibrantPopTheme.radiusSm),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: isSelected
          ? VibrantPopTheme.primaryButtonDecoration(
              VibrantPopTheme.primary)
          : VibrantPopTheme.chipDecoration,
      child: Center(
        child: Text(
          label,
          style: VibrantPopTheme.caption.copyWith(
            color: isSelected
                ? Colors.white
                : VibrantPopTheme.text,
            fontWeight: FontWeight.w700,
          ),
        ),
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
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) =>
          _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(DemoProduct product) {
    return Container(
      decoration: VibrantPopTheme.cardDecoration,
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
                    color: VibrantPopTheme.surface,
                    child: Center(
                      child: Icon(Icons.shopping_bag_rounded,
                          size: 32,
                          color: VibrantPopTheme.primary
                              .withValues(alpha: 0.3)),
                    ),
                  ),
                ),
                // Condition badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(
                          VibrantPopTheme.radiusFull),
                    ),
                    child: Text(
                      product.condition,
                      style: VibrantPopTheme.caption.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: VibrantPopTheme.primary,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 16,
                      color: VibrantPopTheme.secondary,
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
              padding:
                  const EdgeInsets.all(VibrantPopTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: VibrantPopTheme.title.copyWith(
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: VibrantPopTheme.subheadline.copyWith(
                      fontSize: 16,
                      color: VibrantPopTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient:
                              VibrantPopTheme.superLikeGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            product.seller[0],
                            style:
                                VibrantPopTheme.caption.copyWith(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.seller,
                          style:
                              VibrantPopTheme.caption.copyWith(
                            fontSize: 10,
                            color:
                                VibrantPopTheme.textSecondary,
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
      backgroundColor: VibrantPopTheme.background,
      activeColor: VibrantPopTheme.primary,
      inactiveColor: VibrantPopTheme.textSecondary,
      fabColor: VibrantPopTheme.accent,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: VibrantPopTheme.caption.copyWith(fontSize: 8),
    );
  }
}
