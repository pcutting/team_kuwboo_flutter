import 'package:flutter/material.dart';
import '../../proto_theme.dart';

/// Shared V2 badge used across all YoYo screens when variant == 1.
Widget yoyoV2Badge(ProtoTheme theme) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: theme.primary,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text(
    'V2',
    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
  ),
);

// ─── Organic avatar (asymmetric border radius) ────────────────────────

/// Organic-shaped avatar using asymmetric [BorderRadius.only].
/// Opposing diagonal corners share the same radius — tight (33%) on
/// top-left / bottom-right, loose (50%) on top-right / bottom-left —
/// producing a distinctive pebble / organic silhouette.
class OrganicAvatar extends StatelessWidget {
  final double size;
  final String imageUrl;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;

  const OrganicAvatar({
    super.key,
    required this.size,
    required this.imageUrl,
    this.borderColor,
    this.borderWidth = 0,
    this.boxShadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    final total = size + borderWidth * 2;
    final tight = size * 0.33;
    final loose = size * 0.5;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(tight),
      topRight: Radius.circular(loose),
      bottomLeft: Radius.circular(loose),
      bottomRight: Radius.circular(tight),
    );
    return Container(
      width: total,
      height: total,
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: radius,
        boxShadow: boxShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}
