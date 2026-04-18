import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'shop_format.dart';
import 'shop_providers.dart';

class ShopProductDetail extends ConsumerStatefulWidget {
  /// Product identifier to hydrate from `GET /products/:id`. When null the
  /// screen renders an empty-state prompt — route builders should pass the
  /// id via `extra: {'productId': ...}`.
  final String? productId;

  const ShopProductDetail({super.key, this.productId});

  @override
  ConsumerState<ShopProductDetail> createState() => _ShopProductDetailState();
}

class _ShopProductDetailState extends ConsumerState<ShopProductDetail> {
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final id = widget.productId;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(
              title: 'Product',
              actions: [
                ProtoPressButton(
                  onTap: () => ProtoShareSheet.show(context),
                  child: Icon(theme.icons.share, size: 20, color: theme.text),
                ),
              ],
            ),
            Expanded(
              child: id == null
                  ? const ProtoEmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No product selected',
                      subtitle: 'Open a listing from the marketplace grid',
                    )
                  : ref
                        .watch(productDetailProvider(id))
                        .when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => ProtoErrorState(
                            message: 'Could not load product',
                            onRetry: () =>
                                ref.invalidate(productDetailProvider(id)),
                          ),
                          data: (product) =>
                              _ProductBody(product: product, theme: theme),
                        ),
            ),
            if (id != null)
              _BuyActionBar(
                productId: id,
                theme: theme,
                isWishlisted: _isWishlisted,
                onToggleWishlist: () {
                  setState(() => _isWishlisted = !_isWishlisted);
                  ProtoToast.show(
                    context,
                    _isWishlisted
                        ? theme.icons.favoriteFilled
                        : theme.icons.favoriteOutline,
                    _isWishlisted
                        ? 'Added to wishlist'
                        : 'Removed from wishlist',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({required this.product, required this.theme});

  final Product product;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final thumbnailUrl = product.thumbnailUrl;
    final title = product.title ?? 'Untitled listing';
    final description = product.description ?? '';
    final condition = product.condition ?? '—';
    final sellerId = product.creatorId;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          ProtoNetworkImage(
            imageUrl: thumbnailUrl,
            height: 280,
            width: double.infinity,
          )
        else
          Container(
            height: 280,
            width: double.infinity,
            color: theme.surface,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                color: theme.textTertiary,
                size: 48,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatPriceCents(product.priceCents, product.currency),
                    style: theme.headline.copyWith(
                      color: theme.primary,
                      fontSize: 28,
                    ),
                  ),
                  if (product.isDeal && product.originalPriceCents != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      formatPriceCents(
                        product.originalPriceCents,
                        product.currency,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(title, style: theme.title.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ProtoPressButton(
                onTap: sellerId == null
                    ? null
                    : () => state.pushWithArgs(ProtoRoutes.shopSeller, {
                        'sellerId': sellerId,
                      }),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: theme.cardDecoration,
                  child: Row(
                    children: [
                      const ProtoAvatar(
                        radius: 20,
                        imageUrl:
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View seller',
                              style: theme.title.copyWith(fontSize: 14),
                            ),
                            Text(
                              'Tap for ratings and other listings',
                              style: theme.caption,
                            ),
                          ],
                        ),
                      ),
                      Icon(theme.icons.chevronRight, color: theme.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Description', style: theme.title),
              const SizedBox(height: 6),
              Text(
                description.isEmpty ? 'No description provided.' : description,
                style: theme.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuyActionBar extends StatelessWidget {
  const _BuyActionBar({
    required this.productId,
    required this.theme,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  final String productId;
  final ProtoTheme theme;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleWishlist,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.text.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isWishlisted
                    ? theme.icons.favoriteFilled
                    : theme.icons.favoriteOutline,
                color: isWishlisted ? theme.accent : theme.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProtoPressButton(
              onTap: () => ProtoToast.show(
                context,
                theme.icons.localOffer,
                'Offer dialog would open',
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Make Offer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProtoPressButton(
              onTap: () async {
                final confirmed = await ProtoConfirmDialog.show(
                  context,
                  title: 'Confirm Purchase',
                  message: 'Proceed to checkout for this listing?',
                );
                if (confirmed && context.mounted) {
                  ProtoToast.show(
                    context,
                    theme.icons.shoppingBag,
                    'Purchase confirmed!',
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
