import 'package:flutter/material.dart';

/// V9: Hyper-Local Street Theme
/// Philosophy: Dating meets neighborhood culture. Urban, authentic, local.
/// Target: 22-32, city dwellers, culture enthusiasts

class HyperLocalStreetTheme {
  // Core palette - street poster aesthetic
  static const Color primary = Color(0xFFE63946); // Marker red
  static const Color secondary = Color(0xFF457B9D); // Spray blue
  static const Color tertiary = Color(0xFFF4A261); // Wheat-paste cream
  static const Color background = Color(0xFFF5F1EB); // Poster paper
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF686868);
  static const Color concrete = Color(0xFFBDBDBD);

  // Typography
  static const String condensedFont = 'Bebas Neue';
  static const String bodyFont = 'Inter';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius - mostly sharp
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;

  // Shadows - paper-like
  static List<BoxShadow> get paperShadow => [
        BoxShadow(
          color: text.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ];

  // Text styles - condensed and bold
  static TextStyle get display => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 2,
        height: 0.9,
      );

  static TextStyle get headline => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 1,
        height: 1.0,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 0.5,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: text,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        letterSpacing: 1,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 1.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: condensedFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: surface,
        letterSpacing: 1,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        boxShadow: paperShadow,
      );

  static BoxDecoration get posterDecoration => BoxDecoration(
        color: surface,
        border: Border.all(color: text, width: 2),
      );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: text, width: 2),
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get tagDecoration => BoxDecoration(
        color: tertiary,
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get locationTagDecoration => BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(radiusSm),
      );
}
