import 'package:flutter/material.dart';

/// V0: Urban Warmth Theme
/// Philosophy: Full-bleed impact meets organic approachability.
/// Blends V5 Organic Warmth (earth tones, rounded shapes) with
/// V9 Hyper-Local Street (bold condensed type, location-forward).
/// Target: 25-35, confident urban professionals who value authenticity

class UrbanWarmthTheme {
  // Core palette — V5 warmth with V9 accent punch
  static const Color primary = Color(0xFFCB6843); // Terracotta (V5)
  static const Color secondary = Color(0xFF7B9E6B); // Sage green (V5)
  static const Color accent = Color(0xFFD4453C); // Warm red (V5/V9 blend)
  static const Color tertiary = Color(0xFFF4A460); // Soft coral (V5)
  static const Color background = Color(0xFFF8F4F0); // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2D2A26); // Warm dark brown
  static const Color textSecondary = Color(0xFF5A4E43);
  static const Color textTertiary = Color(0xFF7A6E62);

  // Typography — V9 condensed display + V5 body warmth
  static const String displayFont = 'Bebas Neue'; // V9 impact
  static const String bodyFont = 'Lato'; // V5 warmth

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius — V5 organic rounds
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusFull = 100.0;

  // Shadows — warm and soft (V5)
  static List<BoxShadow> get warmShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: text.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Text styles — V9 condensed display, V5 warm body
  static TextStyle get display => const TextStyle(
        fontFamily: displayFont,
        fontSize: 44,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        letterSpacing: 2,
        height: 0.95,
      );

  static TextStyle get headline => const TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 1,
        height: 1.0,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 0.5,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
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

  static TextStyle get caption => const TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: displayFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: text,
        letterSpacing: 1.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: displayFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: surface,
        letterSpacing: 1,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  static BoxDecoration get pillDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radiusFull),
      );

  static BoxDecoration accentPillDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radiusFull),
      );

  static List<BoxShadow> colorShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
