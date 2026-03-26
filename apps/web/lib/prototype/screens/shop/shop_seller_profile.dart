import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

class ShopSellerProfile extends StatefulWidget {
  const ShopSellerProfile({super.key});

  @override
  State<ShopSellerProfile> createState() => _ShopSellerProfileState();
}

class _ShopSellerProfileState extends State<ShopSellerProfile> {
  String _activeTab = 'Active';
  bool _isFollowing = false;
  bool _isFriend = false;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Seller',
            actions: [
              ProtoPressButton(
                onTap: () => ProtoShareSheet.show(context),
                child: Icon(theme.icons.share, size: 20, color: theme.text),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      ProtoAvatar(radius: 40, imageUrl: DemoData.nearbyUsers[0].imageUrl),
                      const SizedBox(height: 10),
                      Text('Maya', style: theme.headline.copyWith(fontSize: 22)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(theme.icons.starFilled, size: 18, color: theme.tertiary),
                          Text(' 4.8', style: theme.title.copyWith(fontSize: 14)),
                          Text(' (23 reviews)', style: theme.caption),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Module badges
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModuleBadge(
                            icon: Icons.storefront_rounded,
                            label: 'Seller',
                            isActive: true,
                            theme: theme,
                            onTap: () => ProtoToast.show(context, Icons.storefront_rounded, "You're viewing Maya's shop"),
                          ),
                          const SizedBox(width: 8),
                          _ModuleBadge(
                            icon: Icons.people_outline_rounded,
                            label: 'Social',
                            isActive: false,
                            theme: theme,
                            onTap: () => state.push(ProtoRoutes.yoyoProfile),
                          ),
                          const SizedBox(width: 8),
                          _ModuleBadge(
                            icon: Icons.videocam_outlined,
                            label: 'Video',
                            isActive: false,
                            theme: theme,
                            onTap: () => state.push(ProtoRoutes.videoCreator),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Friend Request / Message buttons + Online indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ProtoPressButton(
                            onTap: () {
                              setState(() => _isFriend = !_isFriend);
                              ProtoToast.show(
                                context,
                                _isFriend ? theme.icons.personAdd : theme.icons.personRemove,
                                _isFriend ? 'Friend request sent' : 'Friend removed',
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isFriend ? theme.secondary : theme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isFriend ? theme.icons.personAdd : theme.icons.personAdd,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isFriend ? 'Friends' : 'Add Friend',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ProtoPressButton(
                            onTap: () => state.push(ProtoRoutes.chatConversation),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.text.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                            ),
                          ),
                          // Online indicator
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: theme.successColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('Online', style: theme.caption.copyWith(color: theme.successColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(count: '3', label: 'Orders'),
                    _Stat(count: '12', label: 'Active'),
                    _Stat(count: '47', label: 'Sold'),
                    _Stat(count: '4.8', label: 'Rating'),
                  ],
                ),
                const SizedBox(height: 20),

                // Tab bar (Orders / Active / Sold / Reviews)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: ['Orders', 'Active', 'Sold', 'Reviews'].map((tab) {
                      final isActive = tab == _activeTab;
                      return Expanded(
                        child: ProtoPressButton(
                          duration: const Duration(milliseconds: 100),
                          onTap: () => setState(() => _activeTab = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? theme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isActive ? theme.softShadow : null,
                            ),
                            child: Center(child: Text(tab, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? theme.text : theme.textTertiary))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Content based on active tab
                if (_activeTab == 'Reviews')
                  _ReviewsList(theme: theme)
                else if (_activeTab == 'Orders')
                  _OrdersList(theme: theme)
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                    children: DemoDataExtended.products.take(_activeTab == 'Sold' ? 4 : 3).map((p) => ProtoPressButton(
                      onTap: () => state.push(ProtoRoutes.shopProduct),
                      child: Container(
                        decoration: theme.cardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ProtoNetworkImage(imageUrl: p.imageUrl, width: double.infinity),
                                  if (_activeTab == 'Sold')
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: theme.secondary, borderRadius: BorderRadius.circular(6)),
                                        child: const Text('SOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.title, style: theme.caption.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('\$${p.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary, fontFamily: theme.displayFont)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Column(
      children: [
        Text(count, style: theme.title.copyWith(fontSize: 18)),
        Text(label, style: theme.caption),
      ],
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final ProtoTheme theme;
  const _ReviewsList({required this.theme});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ('Alex', 5, 'Great seller! Item exactly as described. Fast shipping too.', '2d ago'),
      ('Jordan', 4, 'Good condition, slightly slower delivery than expected.', '1w ago'),
      ('Sam', 5, 'Amazing quality. Would buy from again!', '2w ago'),
      ('Riley', 3, 'Decent item but packaging could be better.', '3w ago'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: theme.cardDecoration,
          child: Row(
            children: [
              Text('4.8', style: theme.headline.copyWith(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < 5 ? theme.icons.starFilled : Icons.star_outline_rounded,
                      size: 16,
                      color: theme.tertiary,
                    )),
                  ),
                  const SizedBox(height: 2),
                  Text('23 reviews', style: theme.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...reviews.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: theme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(r.$1, style: theme.title.copyWith(fontSize: 14)),
                  const Spacer(),
                  ...List.generate(5, (i) => Icon(
                    i < r.$2 ? theme.icons.starFilled : Icons.star_outline_rounded,
                    size: 12,
                    color: i < r.$2 ? theme.tertiary : theme.textTertiary,
                  )),
                ],
              ),
              const SizedBox(height: 6),
              Text(r.$3, style: theme.body),
              const SizedBox(height: 4),
              Text(r.$4, style: theme.caption),
            ],
          ),
        )),
      ],
    );
  }
}

class _OrdersList extends StatelessWidget {
  final ProtoTheme theme;
  const _OrdersList({required this.theme});

  @override
  Widget build(BuildContext context) {
    final orders = [
      ('Polaroid Camera', 42, 'Delivered', 'Feb 18', 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=200&h=200&fit=crop'),
      ('Vinyl Records', 100, 'Shipped', 'Feb 20', 'https://images.unsplash.com/photo-1539375665275-f9de415ef9ac?w=200&h=200&fit=crop'),
      ('Leather Bag', 70, 'Processing', 'Today', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200&h=200&fit=crop'),
    ];

    return Column(
      children: orders.map((o) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            ProtoNetworkImage(
              imageUrl: o.$5,
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.$1, style: theme.title.copyWith(fontSize: 14)),
                  Text(o.$4, style: theme.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${o.$2}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: o.$3 == 'Delivered'
                        ? theme.successColor.withValues(alpha: 0.1)
                        : o.$3 == 'Shipped'
                            ? theme.secondary.withValues(alpha: 0.1)
                            : theme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    o.$3,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: o.$3 == 'Delivered'
                          ? theme.successColor
                          : o.$3 == 'Shipped'
                              ? theme.secondary
                              : theme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final ProtoTheme theme;
  final VoidCallback onTap;

  const _ModuleBadge({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProtoPressButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : theme.background,
          borderRadius: BorderRadius.circular(14),
          border: isActive ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : theme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
