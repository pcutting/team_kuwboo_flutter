import 'package:flutter/material.dart';
import '../../v9-hyper-local-street/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V9: Hyper-Local Street Marketplace Browse (Set C - Service Switcher FAB)
/// "LOCAL MARKET" header feel, poster borders, condensed type, bold search

class MarketBrowse extends StatelessWidget {
  const MarketBrowse({super.key});

  static const _categories = [
    'ALL',
    'VINTAGE',
    'HANDMADE',
    'FASHION',
    'TECH',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HyperLocalStreetTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: HyperLocalStreetTheme.background,
                  accentColor: HyperLocalStreetTheme.primary,
                  textColor: HyperLocalStreetTheme.text,
                ),
                // "LOCAL MARKET" header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HyperLocalStreetTheme.spacingMd),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'LOCAL MARKET',
                      style: HyperLocalStreetTheme.headline.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: HyperLocalStreetTheme.spacingSm),
                // Search bar with outlineButtonDecoration (2px border)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HyperLocalStreetTheme.spacingMd),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: HyperLocalStreetTheme.spacingSm),
                // Categories
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: HyperLocalStreetTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: HyperLocalStreetTheme.spacingSm,
                          vertical: HyperLocalStreetTheme.spacingXs,
                        ),
                        decoration: isSelected
                            ? HyperLocalStreetTheme
                                .primaryButtonDecoration
                            : HyperLocalStreetTheme
                                .outlineButtonDecoration,
                        child: Center(
                          child: Text(
                            _categories[index],
                            style:
                                HyperLocalStreetTheme.label.copyWith(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : HyperLocalStreetTheme.text,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: HyperLocalStreetTheme.spacingMd),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HyperLocalStreetTheme.spacingMd),
                    child: _buildProductGrid(),
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
            Positioned(
                left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: HyperLocalStreetTheme.outlineButtonDecoration.copyWith(
        color: HyperLocalStreetTheme.surface,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded,
              size: 20, color: HyperLocalStreetTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'SEARCH LOCAL MARKET...',
              style: HyperLocalStreetTheme.label.copyWith(
                color: HyperLocalStreetTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 20,
            color: HyperLocalStreetTheme.concrete,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.tune_rounded,
              size: 18, color: HyperLocalStreetTheme.text),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = DemoDataExtended.products;
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
      decoration: HyperLocalStreetTheme.posterDecoration,
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
                  color: HyperLocalStreetTheme.surface,
                  child: const Center(
                    child: Icon(Icons.shopping_bag_rounded, size: 32),
                  ),
                ),
              ),
            ),
          ),
          // Divider
          Container(height: 2, color: HyperLocalStreetTheme.text),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.all(HyperLocalStreetTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title in condensed uppercase
                  Text(
                    product.title.toUpperCase(),
                    style: HyperLocalStreetTheme.subheadline
                        .copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Price in marker red with Bebas font
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: HyperLocalStreetTheme.headline.copyWith(
                      fontSize: 20,
                      color: HyperLocalStreetTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  // Seller + condition
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.seller.toUpperCase(),
                          style:
                              HyperLocalStreetTheme.label.copyWith(
                            fontSize: 9,
                            color:
                                HyperLocalStreetTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration:
                            HyperLocalStreetTheme.tagDecoration,
                        child: Text(
                          product.condition.toUpperCase(),
                          style:
                              HyperLocalStreetTheme.label.copyWith(
                            fontSize: 8,
                          ),
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
      backgroundColor: HyperLocalStreetTheme.surface,
      activeColor: HyperLocalStreetTheme.primary,
      inactiveColor: HyperLocalStreetTheme.textSecondary,
      fabColor: HyperLocalStreetTheme.primary,
      fabIconColor: HyperLocalStreetTheme.surface,
      borderColor: HyperLocalStreetTheme.text,
      height: 52,
      fabSize: 50,
      labelStyle: HyperLocalStreetTheme.label.copyWith(fontSize: 8),
    );
  }
}
