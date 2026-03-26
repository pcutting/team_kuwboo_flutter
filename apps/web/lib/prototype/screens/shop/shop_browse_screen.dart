import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import '../sponsored/sponsored_inline.dart';
import '../../shared/proto_states.dart';

class ShopBrowseScreen extends StatefulWidget {
  const ShopBrowseScreen({super.key});

  @override
  State<ShopBrowseScreen> createState() => _ShopBrowseScreenState();
}

class _ShopBrowseScreenState extends State<ShopBrowseScreen> {
  String _selectedCategory = 'All';
  final Set<int> _wishlistedIndices = {};

  static const _categories = ['All', 'Electronics', 'Fashion', 'Home', 'Sports', 'Vintage'];

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return ProtoScaffold(
      activeModule: ProtoModule.shop,
      body: DemoDataExtended.products.isEmpty
          ? const ProtoEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No listings nearby',
              subtitle: 'Check back soon or expand your search area',
              actionLabel: 'Sell Something',
            )
          : ListView(
        padding: EdgeInsets.zero,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => ProtoToast.show(context, theme.icons.search, 'Search keyboard would open'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(theme.radiusFull),
                  border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Icon(theme.icons.search, size: 20, color: theme.textTertiary),
                    const SizedBox(width: 10),
                    Text('Search marketplace...', style: theme.body.copyWith(color: theme.textTertiary)),
                  ],
                ),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((cat) {
                final isActive = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ProtoPressButton(
                    duration: const Duration(milliseconds: 100),
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Product grid (2 columns) with sponsored cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: DemoDataExtended.products.length + 1, // +1 for sponsored
              itemBuilder: (context, i) {
                // Insert sponsored product card at position 3
                if (i == 3) {
                  return ProtoPressButton(
                    onTap: () => ProtoToast.show(context, theme.icons.campaign, 'Promoted listing tapped'),
                    child: SponsoredProductCard(
                      brandName: 'TechGear UK',
                      title: 'Pro Wireless Earbuds',
                      price: '£49',
                    ),
                  );
                }
                final productIndex = i < 3 ? i : i - 1;
                if (productIndex >= DemoDataExtended.products.length) {
                  return const SizedBox.shrink();
                }
                final product = DemoDataExtended.products[productIndex];
                final isWishlisted = _wishlistedIndices.contains(productIndex);
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
                          child: ProtoNetworkImage(
                            imageUrl: product.imageUrl,
                            width: double.infinity,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.title, style: theme.title.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(product.condition, style: theme.caption),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.primary, fontFamily: theme.displayFont),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          if (isWishlisted) {
                                            _wishlistedIndices.remove(productIndex);
                                          } else {
                                            _wishlistedIndices.add(productIndex);
                                          }
                                        });
                                        ProtoToast.show(
                                          context,
                                          isWishlisted ? theme.icons.favoriteOutline : theme.icons.favoriteFilled,
                                          isWishlisted ? 'Removed from wishlist' : 'Added to wishlist',
                                        );
                                      },
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          isWishlisted ? theme.icons.favoriteFilled : theme.icons.favoriteOutline,
                                          key: ValueKey(isWishlisted),
                                          size: 16,
                                          color: isWishlisted ? theme.accent : theme.textTertiary,
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
