import 'package:flutter/material.dart';

/// V5: Organic Warmth Theme
/// Philosophy: Human connection in a digital age. Soft, natural, approachable.
/// Target: 25-40, relationship-seekers, tired of swipe culture

class OrganicWarmthTheme {
  // Core palette - earth tones
  static const Color primary = Color(0xFFCB6843); // Terracotta
  static const Color secondary = Color(0xFF7B9E6B); // Sage green
  static const Color tertiary = Color(0xFFF4A460); // Soft coral
  static const Color background = Color(0xFFFDF8F4); // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF3D3229); // Warm brown
  static const Color textSecondary = Color(0xFF5A4E43);
  static const Color textTertiary = Color(0xFF7A6E62);

  // Typography
  static const String fontFamily = 'Lato';
  static const String displayFont = 'Playfair Display';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius - organic curves
  static const double radiusSm = 12.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 28.0;
  static const double radiusBlob = 40.0;

  // Shadows - warm and soft
  static List<BoxShadow> get warmShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: text.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Text styles
  static TextStyle get headline => const TextStyle(
        fontFamily: displayFont,
        fontSize: 30,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: text,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
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
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: surface,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  static BoxDecoration get blobDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusBlob),
          topRight: Radius.circular(radiusMd),
          bottomLeft: Radius.circular(radiusMd),
          bottomRight: Radius.circular(radiusBlob),
        ),
        boxShadow: softShadow,
      );

  static BoxDecoration primaryButtonDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: warmShadow,
      );

  static BoxDecoration get pillDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radiusBlob),
      );

  static BoxDecoration accentPillDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radiusBlob),
      );
}
