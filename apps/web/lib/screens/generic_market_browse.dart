import 'package:flutter/material.dart';
import '../widgets/kuwboo_top_bar.dart';
import '../data/demo_data.dart';

/// Generic marketplace browse — parameterized by colors + nav widget.
/// Search bar + category chips + 2-column product grid.

class GenericMarketBrowse extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Widget bottomNav;

  const GenericMarketBrowse({
    super.key,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.bottomNav,
  });

  static const _categories = ['All', 'Vintage', 'Handmade', 'Fashion', 'Tech'];

  Color get _textSecondary => text.withValues(alpha: 0.6);
  Color get _textTertiary => text.withValues(alpha: 0.4);
  Color get _divider => text.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: background,
                  accentColor: primary,
                  textColor: text,
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 8),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final isSelected = index == 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? text : surface,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? null
                              : Border.all(color: _divider),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? surface : _textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
              child: bottomNav,
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
        color: surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 18, color: _textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search marketplace...',
              style: TextStyle(fontSize: 13, color: _textTertiary),
            ),
          ),
          Icon(Icons.tune_rounded, size: 18, color: _textTertiary),
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
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  color: _divider,
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 32,
                      color: _textTertiary,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: secondary,
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
                          color: primary.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            product.seller[0],
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.seller,
                          style: TextStyle(fontSize: 10, color: _textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.condition,
                          style: TextStyle(fontSize: 8, color: _textSecondary),
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
}
