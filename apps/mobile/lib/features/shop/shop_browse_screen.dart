import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Grid-based marketplace browse screen with search and filters.
class ShopBrowseScreen extends StatefulWidget {
  const ShopBrowseScreen({super.key});

  @override
  State<ShopBrowseScreen> createState() => _ShopBrowseScreenState();
}

class _ShopBrowseScreenState extends State<ShopBrowseScreen> {
  final _searchController = TextEditingController();
  String? _selectedCondition;
  bool _isLoading = false;

  // Demo products for UI scaffolding until backend is ready.
  final _products = List.generate(
    12,
    (i) => Product(
      id: 'prod_$i',
      creatorId: 'user_${i % 4}',
      title: _demoTitles[i % _demoTitles.length],
      description: 'Product description for item $i',
      priceCents: (500 + i * 350),
      condition: _demoConditions[i % _demoConditions.length],
      isDeal: i % 3 == 0,
      originalPriceCents: i % 3 == 0 ? (800 + i * 350) : null,
      likeCount: i * 3,
      commentCount: i,
      createdAt: DateTime.now().subtract(Duration(hours: i * 6)),
    ),
  );

  static const _demoTitles = [
    'Vintage Leather Jacket',
    'Wireless Headphones',
    'Running Trainers',
    'Retro Camera',
    'Handmade Ceramic Mug',
    'Mechanical Keyboard',
    'Yoga Mat',
    'Denim Backpack',
    'Sunglasses',
    'Bluetooth Speaker',
    'Art Print',
    'Watch',
  ];

  static const _demoConditions = ['NEW', 'LIKE_NEW', 'GOOD', 'FAIR'];

  static const _conditionLabels = {
    'NEW': 'New',
    'LIKE_NEW': 'Like New',
    'GOOD': 'Good',
    'FAIR': 'Fair',
  };

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    // TODO: call MarketplaceApi.getProducts()
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  List<Product> get _filteredProducts {
    var list = _products;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((p) => p.title.toLowerCase().contains(query))
          .toList();
    }
    if (_selectedCondition != null) {
      list = list.where((p) => p.condition == _selectedCondition).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCondition == null,
                    onSelected: (_) =>
                        setState(() => _selectedCondition = null),
                  ),
                ),
                for (final entry in _conditionLabels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: _selectedCondition == entry.key,
                      onSelected: (selected) => setState(
                        () => _selectedCondition =
                            selected ? entry.key : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _ProductCard(product: filtered[index]),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/shop/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  String _formatPrice(int cents) {
    final pounds = cents / 100;
    return '\u00a3${pounds.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/shop/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    if (product.isDeal)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DEAL',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.priceCents),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (product.isDeal &&
                          product.originalPriceCents != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          _formatPrice(product.originalPriceCents!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.condition.replaceAll('_', ' '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
