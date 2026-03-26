import 'package:flutter/material.dart';
import '../../v2-soft-luxury/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V2: Soft Luxury Marketplace Browse (Set C - Service Switcher FAB)
/// Elegant product grid with editorial photography

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SoftLuxuryTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: SoftLuxuryTheme.background,
                  accentColor: SoftLuxuryTheme.primary,
                  textColor: SoftLuxuryTheme.text,
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SoftLuxuryTheme.spacingMd,
                  ),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: SoftLuxuryTheme.spacingSm),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SoftLuxuryTheme.spacingMd,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SoftLuxuryTheme.spacingMd,
                          vertical: SoftLuxuryTheme.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SoftLuxuryTheme.text
                              : SoftLuxuryTheme.surface,
                          borderRadius:
                              BorderRadius.circular(SoftLuxuryTheme.radiusSm),
                          border: isSelected
                              ? null
                              : Border.all(color: SoftLuxuryTheme.divider),
                        ),
                        child: Text(
                          _categories[index],
                          style: SoftLuxuryTheme.caption.copyWith(
                            color: isSelected
                                ? SoftLuxuryTheme.surface
                                : SoftLuxuryTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: SoftLuxuryTheme.spacingMd),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SoftLuxuryTheme.spacingMd,
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
      height: 40,
      decoration: BoxDecoration(
        color: SoftLuxuryTheme.surface,
        borderRadius: BorderRadius.circular(SoftLuxuryTheme.radiusSm),
        boxShadow: SoftLuxuryTheme.subtleShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: SoftLuxuryTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search marketplace...',
              style: SoftLuxuryTheme.body.copyWith(
                fontSize: 13,
                color: SoftLuxuryTheme.textTertiary,
              ),
            ),
          ),
          Icon(
            Icons.tune_rounded,
            size: 18,
            color: SoftLuxuryTheme.textTertiary,
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
      decoration: SoftLuxuryTheme.cardDecoration,
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
                  color: SoftLuxuryTheme.divider,
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 32,
                      color: SoftLuxuryTheme.textTertiary,
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
              padding: const EdgeInsets.symmetric(horizontal: SoftLuxuryTheme.spacingSm, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: SoftLuxuryTheme.title.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: SoftLuxuryTheme.title.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SoftLuxuryTheme.secondary,
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
                          color:
                              SoftLuxuryTheme.primary.withValues(alpha: 0.2),
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
                          style:
                              SoftLuxuryTheme.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: SoftLuxuryTheme.tagDecoration,
                        child: Text(
                          product.condition,
                          style:
                              SoftLuxuryTheme.caption.copyWith(fontSize: 8),
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
      backgroundColor: SoftLuxuryTheme.surface,
      activeColor: SoftLuxuryTheme.primary,
      inactiveColor: SoftLuxuryTheme.textSecondary,
      fabColor: SoftLuxuryTheme.secondary,
      fabIconColor: SoftLuxuryTheme.surface,
      borderColor: SoftLuxuryTheme.divider,
      height: 52,
      fabSize: 50,
      labelStyle: SoftLuxuryTheme.caption.copyWith(fontSize: 8),
    );
  }
}
