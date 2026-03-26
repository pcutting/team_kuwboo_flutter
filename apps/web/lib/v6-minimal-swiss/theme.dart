import 'package:flutter/material.dart';

/// V6: Minimal Swiss Theme
/// Philosophy: Information clarity. Let content breathe.
/// Target: 30-45, design-conscious, minimalists

class MinimalSwissTheme {
  // Core palette - strict
  static const Color primary = Color(0xFFE53935); // Swiss red
  static const Color secondary = Color(0xFF1976D2); // Blue accent
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color divider = Color(0xFFE0E0E0);

  // Typography - Helvetica-inspired
  static const String fontFamily = 'Helvetica Neue';

  // Grid system - 8px base
  static const double grid = 8.0;
  static const double spacingXs = 4.0; // 0.5 grid
  static const double spacingSm = 8.0; // 1 grid
  static const double spacingMd = 16.0; // 2 grid
  static const double spacingLg = 24.0; // 3 grid
  static const double spacingXl = 32.0; // 4 grid
  static const double spacingXxl = 48.0; // 6 grid

  // Border radius - minimal
  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0;

  // Text styles - strict hierarchy
  static TextStyle get headline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: text,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: -0.5,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: text,
        letterSpacing: 0,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.6,
        letterSpacing: 0,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 1.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: background,
        letterSpacing: 0.5,
      );

  // Component decorations - no shadows, minimal borders
  static BoxDecoration get cardDecoration => const BoxDecoration(
        color: background,
      );

  static BoxDecoration get borderedDecoration => BoxDecoration(
        color: background,
        border: Border.all(color: divider, width: 1),
      );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: text,
        borderRadius: BorderRadius.circular(radiusSm),
      );

  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: text, width: 1),
        borderRadius: BorderRadius.circular(radiusSm),
      );

  // Dividers
  static Widget get horizontalDivider => Container(
        height: 1,
        color: divider,
      );

  static Widget get verticalDivider => Container(
        width: 1,
        color: divider,
      );
}
