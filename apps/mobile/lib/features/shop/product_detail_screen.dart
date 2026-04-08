import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Full product detail view with seller info and action buttons.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  // Demo product for UI scaffolding.
  Product get _demoProduct => Product(
        id: productId,
        creatorId: 'user_1',
        title: 'Vintage Leather Jacket',
        description:
            'Beautiful vintage leather jacket in excellent condition. '
            'Genuine leather, size M. Perfect for autumn and winter. '
            'Minor wear on the cuffs but otherwise pristine.',
        priceCents: 4500,
        condition: 'LIKE_NEW',
        isDeal: true,
        originalPriceCents: 7500,
        likeCount: 24,
        commentCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

  String _formatPrice(int cents) {
    final pounds = cents / 100;
    return '\u00a3${pounds.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _demoProduct;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: toggle like
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: toggle save
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 300,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & price
                  Text(
                    product.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.priceCents),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (product.isDeal &&
                          product.originalPriceCents != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          _formatPrice(product.originalPriceCents!),
                          style: theme.textTheme.titleLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Condition badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.condition.replaceAll('_', ' '),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Seller info card
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.person),
                      ),
                      title: const Text('Seller Name'),
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          const Text('4.8 (23 reviews)'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      Icon(Icons.favorite_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${product.likeCount} likes'),
                      const SizedBox(width: 16),
                      Icon(Icons.comment_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${product.commentCount} comments'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: create thread via MessagingApi, navigate to chat
                    context.push('/chat/thread_new');
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message Seller'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: handle buy / offer flow
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
