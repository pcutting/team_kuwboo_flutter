import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

/// Standalone sponsored content page (reached via route).
class SponsoredInline extends StatelessWidget {
  const SponsoredInline({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(title: 'Sponsored'),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SponsoredPostCard(
                  brandName: 'Brand Name',
                  headline: 'Discover something new today',
                  description: 'Your next favorite find is just a tap away.',
                  ctaText: 'Learn More',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable sponsored post card for embedding in social/video/shop feeds.
class SponsoredPostCard extends StatelessWidget {
  final String brandName;
  final String headline;
  final String description;
  final String ctaText;
  final String? imageUrl;
  final VoidCallback? onTap;

  const SponsoredPostCard({
    super.key,
    required this.brandName,
    required this.headline,
    required this.description,
    this.ctaText = 'Learn More',
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      decoration: theme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad image / gradient header
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
              gradient: imageUrl == null
                  ? LinearGradient(colors: [theme.primary, theme.secondary])
                  : null,
            ),
            child: imageUrl == null
                ? Center(
                    child: Icon(theme.icons.campaign, size: 36, color: Colors.white.withValues(alpha: 0.6)),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand row with "Sponsored" badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sponsored',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.textTertiary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(brandName, style: theme.title.copyWith(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(headline, style: theme.title.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: theme.body.copyWith(color: theme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                ProtoPressButton(
                  onTap: onTap ?? () => ProtoToast.show(context, theme.icons.campaign, 'Ad link tapped'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(ctaText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact sponsored card for product grids (shop browse).
class SponsoredProductCard extends StatelessWidget {
  final String brandName;
  final String title;
  final String price;
  const SponsoredProductCard({super.key, required this.brandName, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      decoration: theme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.primary.withValues(alpha: 0.7), theme.secondary.withValues(alpha: 0.7)],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(theme.icons.campaign, size: 32, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Promoted',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.title.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(brandName, style: theme.caption),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        price,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.primary, fontFamily: theme.displayFont),
                      ),
                      const Spacer(),
                      Icon(theme.icons.campaign, size: 14, color: theme.textTertiary),
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

/// Compact sponsored video overlay for the video feed.
class SponsoredVideoOverlay extends StatelessWidget {
  final String brandName;
  final String caption;
  final String ctaText;
  const SponsoredVideoOverlay({super.key, required this.brandName, required this.caption, this.ctaText = 'Learn More'});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Positioned(
      left: 16,
      bottom: 20,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sponsored badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Sponsored',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          // Brand
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
                ),
                child: Icon(theme.icons.storefront, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                brandName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // CTA button
          ProtoPressButton(
            onTap: () => ProtoToast.show(context, theme.icons.campaign, 'Ad link tapped'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ctaText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
