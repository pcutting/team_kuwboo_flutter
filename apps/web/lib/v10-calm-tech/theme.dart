import 'package:flutter/material.dart';

/// V10: Calm Tech Theme
/// Philosophy: Dating without anxiety. Gentle, pressure-free, mindful.
/// Target: 25-40, anxious daters, introverts, second-chancers

class CalmTechTheme {
  // Core palette - soft and calming
  static const Color primary = Color(0xFFA78BFA); // Soft lavender
  static const Color secondary = Color(0xFF86EFAC); // Pale mint
  static const Color tertiary = Color(0xFFFDA4AF); // Blush
  static const Color background = Color(0xFFF8F7FF); // Soft lavender tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // Typography
  static const String fontFamily = 'DM Sans';

  // Spacing - generous breathing room
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius - soft and friendly
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // Shadows - barely there
  static List<BoxShadow> get gentleShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: text.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Text styles - rounded and friendly
  static TextStyle get headline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: text,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: text,
        height: 1.4,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: text,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.6,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: surface,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusXl),
        boxShadow: gentleShadow,
      );

  static BoxDecoration get softCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: subtleShadow,
      );

  static BoxDecoration primaryButtonDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: divider, width: 1.5),
      );

  static BoxDecoration pillDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radiusLg),
      );
}
