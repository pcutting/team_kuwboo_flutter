import 'package:flutter/material.dart';
import '../../v5-organic-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V5: Organic Warmth Marketplace Browse (Set C - Service Switcher FAB)
/// Warm product grid with organic card styling

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OrganicWarmthTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: OrganicWarmthTheme.background,
                  accentColor: OrganicWarmthTheme.primary,
                  textColor: OrganicWarmthTheme.text,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: OrganicWarmthTheme.spacingSm),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: OrganicWarmthTheme.spacingMd,
                          vertical: OrganicWarmthTheme.spacingSm,
                        ),
                        decoration: isSelected
                            ? OrganicWarmthTheme.accentPillDecoration(OrganicWarmthTheme.primary)
                            : OrganicWarmthTheme.pillDecoration,
                        child: Text(
                          _categories[index],
                          style: OrganicWarmthTheme.caption.copyWith(
                            color: isSelected ? OrganicWarmthTheme.primary : OrganicWarmthTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: OrganicWarmthTheme.spacingMd),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd),
                    child: _buildProductGrid(),
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
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
        color: OrganicWarmthTheme.surface,
        borderRadius: BorderRadius.circular(OrganicWarmthTheme.radiusBlob),
        boxShadow: OrganicWarmthTheme.softShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 18, color: OrganicWarmthTheme.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Search marketplace...', style: OrganicWarmthTheme.body.copyWith(fontSize: 13, color: OrganicWarmthTheme.textTertiary)),
          ),
          Icon(Icons.tune_rounded, size: 18, color: OrganicWarmthTheme.textTertiary),
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
      decoration: OrganicWarmthTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: Image.network(product.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: OrganicWarmthTheme.tertiary.withValues(alpha: 0.2),
                  child: Center(child: Icon(Icons.shopping_bag_rounded, size: 32, color: OrganicWarmthTheme.textTertiary)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(OrganicWarmthTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: OrganicWarmthTheme.title.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('\$${product.price.toStringAsFixed(2)}', style: OrganicWarmthTheme.title.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: OrganicWarmthTheme.primary)),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: OrganicWarmthTheme.secondary.withValues(alpha: 0.2)),
                        child: Center(child: Text(product.seller[0], style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600))),
                      ),
                      const SizedBox(width: 4),
                      Expanded(child: Text(product.seller, style: OrganicWarmthTheme.caption.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: OrganicWarmthTheme.pillDecoration,
                        child: Text(product.condition, style: OrganicWarmthTheme.caption.copyWith(fontSize: 8)),
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
      backgroundColor: OrganicWarmthTheme.surface,
      activeColor: OrganicWarmthTheme.primary,
      inactiveColor: OrganicWarmthTheme.textSecondary,
      fabColor: OrganicWarmthTheme.primary,
      fabIconColor: OrganicWarmthTheme.surface,
      borderColor: OrganicWarmthTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: OrganicWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}
