import 'package:flutter/material.dart';
import '../../v6-minimal-swiss/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V6: Minimal Swiss Marketplace Browse (Set C - Service Switcher FAB)
/// Clean grid, bordered decorations, black/outline chip toggle, red price accent

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MinimalSwissTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: MinimalSwissTheme.background,
                  accentColor: MinimalSwissTheme.primary,
                  textColor: MinimalSwissTheme.text,
                  padding: const EdgeInsets.symmetric(
                    horizontal: MinimalSwissTheme.spacingMd,
                    vertical: MinimalSwissTheme.spacingSm,
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: MinimalSwissTheme.spacingMd),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: MinimalSwissTheme.spacingSm),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: MinimalSwissTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return _buildCategoryChip(
                          _categories[index], isSelected);
                    },
                  ),
                ),
                const SizedBox(height: MinimalSwissTheme.spacingSm),
                MinimalSwissTheme.horizontalDivider,
                const SizedBox(height: MinimalSwissTheme.spacingMd),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: MinimalSwissTheme.spacingMd),
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
      decoration: MinimalSwissTheme.borderedDecoration,
      child: Row(
        children: [
          const SizedBox(width: MinimalSwissTheme.spacingSm),
          const Icon(Icons.search_rounded,
              size: 18, color: MinimalSwissTheme.textTertiary),
          const SizedBox(width: MinimalSwissTheme.spacingSm),
          Expanded(
            child: Text('Search marketplace',
                style: MinimalSwissTheme.body
                    .copyWith(color: MinimalSwissTheme.textTertiary)),
          ),
          Container(
            width: 1,
            height: 24,
            color: MinimalSwissTheme.divider,
          ),
          const SizedBox(width: MinimalSwissTheme.spacingSm),
          const Icon(Icons.tune_rounded,
              size: 18, color: MinimalSwissTheme.textSecondary),
          const SizedBox(width: MinimalSwissTheme.spacingSm),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: MinimalSwissTheme.spacingXs),
      padding: const EdgeInsets.symmetric(
        horizontal: MinimalSwissTheme.spacingSm,
        vertical: MinimalSwissTheme.spacingXs,
      ),
      decoration: isSelected
          ? MinimalSwissTheme.primaryButtonDecoration
          : MinimalSwissTheme.outlineButtonDecoration,
      child: Center(
        child: Text(
          label,
          style: isSelected
              ? MinimalSwissTheme.button
              : MinimalSwissTheme.caption
                  .copyWith(color: MinimalSwissTheme.text),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = DemoDataExtended.products;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: MinimalSwissTheme.spacingSm,
        mainAxisSpacing: MinimalSwissTheme.spacingSm,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.only(bottom: MinimalSwissTheme.spacingMd),
      itemBuilder: (context, index) =>
          _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(DemoProduct product) {
    return Container(
      decoration: MinimalSwissTheme.borderedDecoration,
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
                  color: MinimalSwissTheme.surface,
                  child: const Center(child: Icon(
                      Icons.shopping_bag_outlined, size: 32,
                      color: MinimalSwissTheme.textTertiary)),
                ),
              ),
            ),
          ),
          // Thin divider between image and info
          MinimalSwissTheme.horizontalDivider,
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(MinimalSwissTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: MinimalSwissTheme.caption
                          .copyWith(color: MinimalSwissTheme.text),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: MinimalSwissTheme.title.copyWith(
                        color: MinimalSwissTheme.primary, fontSize: 15),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(product.seller,
                            style: MinimalSwissTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: MinimalSwissTheme.borderedDecoration,
                        child: Text(product.condition,
                            style: MinimalSwissTheme.caption
                                .copyWith(fontSize: 9)),
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
      backgroundColor: MinimalSwissTheme.background,
      activeColor: MinimalSwissTheme.primary,
      inactiveColor: MinimalSwissTheme.textTertiary,
      fabColor: MinimalSwissTheme.primary,
      fabIconColor: MinimalSwissTheme.background,
      borderColor: MinimalSwissTheme.divider,
      height: 52,
      fabSize: 50,
      labelStyle: MinimalSwissTheme.label.copyWith(fontSize: 8),
    );
  }
}
