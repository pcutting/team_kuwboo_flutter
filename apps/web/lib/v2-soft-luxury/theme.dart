import 'package:flutter/material.dart';

/// V2: Soft Luxury Theme
/// Philosophy: Whisper, don't shout. Premium dating for discerning users.
/// Target: 28-40, professionals, quality over quantity

class SoftLuxuryTheme {
  // Core palette - muted and sophisticated
  static const Color primary = Color(0xFFB8956F); // Muted gold
  static const Color secondary = Color(0xFF722F37); // Deep burgundy
  static const Color background = Color(0xFFFAF8F5); // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2D2926); // Warm charcoal
  static const Color textSecondary = Color(0xFF5A5550);
  static const Color textTertiary = Color(0xFF7A746E);
  static const Color divider = Color(0xFFE8E4DF);

  // Typography
  static const String serifFont = 'Playfair Display';
  static const String sansFont = 'Inter';

  // Spacing - generous
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius - soft curves
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;

  // Shadows - soft and subtle
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF2D2926).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: const Color(0xFF2D2926).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Text styles
  static TextStyle get headline => const TextStyle(
        fontFamily: serifFont,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: serifFont,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: sansFont,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: sansFont,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0,
        height: 1.6,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: sansFont,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: sansFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: sansFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        letterSpacing: 1.2,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: sansFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: surface,
        letterSpacing: 0.3,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  static BoxDecoration get surfaceDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: subtleShadow,
      );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: text,
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: divider, width: 1),
      );

  static BoxDecoration get tagDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get accentTagDecoration => BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radiusSm),
      );

  // Hairline divider
  static Widget get hairlineDivider => Container(
        height: 0.5,
        color: divider,
      );
}
