import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
import '../sponsored/sponsored_inline.dart';
import 'shop_format.dart';
import 'shop_providers.dart';

class ShopBrowseScreen extends ConsumerStatefulWidget {
  const ShopBrowseScreen({super.key});

  @override
  ConsumerState<ShopBrowseScreen> createState() => _ShopBrowseScreenState();
}

class _ShopBrowseScreenState extends ConsumerState<ShopBrowseScreen> {
  String _selectedCategory = 'All';
  final Set<String> _wishlistedIds = {};

  static const _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Vintage',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final filters = ShopFilters(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    final async = ref.watch(shopBrowseProvider(filters));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Semantics(
            identifier: ScreensIds.shopBrowseSearch,
            textField: true,
            label: 'Search marketplace',
            child: GestureDetector(
              onTap: () => ProtoToast.show(
                context,
                theme.icons.search,
                'Search keyboard would open',
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(theme.radiusFull),
                  border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Icon(theme.icons.search,
                        size: 20, color: theme.textTertiary),
                    const SizedBox(width: 10),
                    Text(
                      'Search marketplace...',
                      style: theme.body.copyWith(color: theme.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _categories.map((cat) {
              final isActive = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  identifier: ScreensIds.shopBrowseCategoryChip(cat),
                  button: true,
                  selected: isActive,
                  label: cat,
                  child: ProtoPressButton(
                    duration: const Duration(milliseconds: 100),
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? null
                            : Border.all(
                                color: theme.text.withValues(alpha: 0.1),
                              ),
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
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ProtoErrorState(
              message: 'Could not load listings',
              onRetry: () => ref.invalidate(shopBrowseProvider(filters)),
            ),
          ),
          data: (page) {
            final products = page.items;
            if (products.isEmpty) {
              return const ProtoEmptyState(
                icon: Icons.storefront_outlined,
                title: 'No listings nearby',
                subtitle: 'Check back soon or expand your search area',
                actionLabel: 'Sell Something',
              );
            }
            return _ProductGrid(
              products: products,
              theme: theme,
              wishlistedIds: _wishlistedIds,
              onWishlistToggle: (id, wasWishlisted) {
                setState(() {
                  if (wasWishlisted) {
                    _wishlistedIds.remove(id);
                  } else {
                    _wishlistedIds.add(id);
                  }
                });
                ProtoToast.show(
                  context,
                  wasWishlisted
                      ? theme.icons.favoriteOutline
                      : theme.icons.favoriteFilled,
                  wasWishlisted
                      ? 'Removed from wishlist'
                      : 'Added to wishlist',
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.theme,
    required this.wishlistedIds,
    required this.onWishlistToggle,
  });

  final List<Product> products;
  final ProtoTheme theme;
  final Set<String> wishlistedIds;
  final void Function(String id, bool wasWishlisted) onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final sponsoredSlot = products.length >= 3 ? 3 : -1;
    final itemCount =
        sponsoredSlot >= 0 ? products.length + 1 : products.length;

    return Padding(
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
        itemCount: itemCount,
        itemBuilder: (context, i) {
          if (i == sponsoredSlot) {
            return ProtoPressButton(
              onTap: () => ProtoToast.show(
                context,
                theme.icons.campaign,
                'Promoted listing tapped',
              ),
              child: SponsoredProductCard(
                brandName: 'TechGear UK',
                title: 'Pro Wireless Earbuds',
                price: '£49',
              ),
            );
          }
          final idx = sponsoredSlot >= 0 && i > sponsoredSlot ? i - 1 : i;
          final product = products[idx];
          // [shopBrowseProvider] filters null-id rows at the provider
          // boundary, but keep a defensive fallback so a bad upstream
          // change can't crash the grid.
          final productId = product.id ?? '';
          final productTitle = product.title ?? 'Untitled listing';
          final isWishlisted = wishlistedIds.contains(productId);
          final priceText = formatPriceCents(
            product.priceCents,
            product.currency,
          );
          return Semantics(
            identifier: ScreensIds.shopBrowseProduct(idx),
            button: true,
            label: productTitle,
            value: '$productTitle $priceText',
            child: ProtoPressButton(
              onTap: () => state.pushWithArgs(
                ProtoRoutes.shopProduct,
                {'productId': productId},
              ),
              child: Container(
                decoration: theme.cardDecoration,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ProductThumbnail(
                        url: product.thumbnailUrl,
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              style: theme.title.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.condition ?? '—',
                              style: theme.caption,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  priceText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primary,
                                    fontFamily: theme.displayFont,
                                  ),
                                ),
                                const Spacer(),
                                Semantics(
                                  identifier:
                                      ScreensIds.shopBrowseWishlist(idx),
                                  button: true,
                                  selected: isWishlisted,
                                  label: isWishlisted
                                      ? 'Remove from wishlist'
                                      : 'Add to wishlist',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        onWishlistToggle(productId, isWishlisted),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        isWishlisted
                                            ? theme.icons.favoriteFilled
                                            : theme.icons.favoriteOutline,
                                        key: ValueKey(isWishlisted),
                                        size: 16,
                                        color: isWishlisted
                                            ? theme.accent
                                            : theme.textTertiary,
                                      ),
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
            ),
          );
        },
      ),
    );
  }
}

/// Product grid thumbnail. Renders [ProtoNetworkImage] when the listing
/// has a real image URL; otherwise falls back to a themed placeholder
/// icon (no stock-image filler — backend `content.thumbnail_url` is
/// rolling out gradually and empty listings should read as "no image
/// yet" rather than "someone's random product photo").
class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({
    required this.url,
    required this.theme,
  });

  final String? url;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    final value = url;
    if (value != null && value.isNotEmpty) {
      return ProtoNetworkImage(imageUrl: value, width: double.infinity);
    }
    return Container(
      width: double.infinity,
      color: theme.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: theme.textTertiary,
          size: 28,
        ),
      ),
    );
  }
}
