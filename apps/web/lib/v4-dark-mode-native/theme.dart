import 'package:flutter/material.dart';

/// V4: Dark Mode Native Theme
/// Philosophy: Night owl dating. Designed for dark, not adapted.
/// Target: 22-35, tech-savvy, night owls, gamers

class DarkModeNativeTheme {
  // Core palette - OLED optimized
  static const Color primary = Color(0xFF8B5CF6); // Purple
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color tertiary = Color(0xFFEC4899); // Pink
  static const Color background = Color(0xFF000000); // True black
  static const Color surface = Color(0xFF0A0A0F);
  static const Color surfaceElevated = Color(0xFF121218);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color border = Color(0xFF1F1F28);

  // Glow effects
  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> subtleGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // Typography
  static const String fontFamily = 'Inter';
  static const String monoFont = 'JetBrains Mono';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Text styles
  static TextStyle get headline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: text,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
        letterSpacing: -0.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: text,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: monoFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: text,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: border, width: 1),
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: border, width: 1),
      );

  static BoxDecoration glowingCardDecoration(Color accentColor) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: subtleGlow(accentColor),
      );

  static BoxDecoration primaryButtonDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: glowShadow(color),
      );

  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: border, width: 1),
      );
}
