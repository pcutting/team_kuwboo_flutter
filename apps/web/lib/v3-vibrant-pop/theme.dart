import 'package:flutter/material.dart';

/// V3: Vibrant Pop Theme
/// Philosophy: Dating should be FUN. Bold, energetic, unapologetically joyful.
/// Target: 21-28, social, extroverted, festival-goers

class VibrantPopTheme {
  // Core palette - saturated and bold
  static const Color primary = Color(0xFF0066FF); // Electric blue
  static const Color secondary = Color(0xFFFF0080); // Hot pink
  static const Color tertiary = Color(0xFF00FF88); // Lime green
  static const Color accent = Color(0xFFFF6600); // Bright orange
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8FF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8D);

  // Gradient combinations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00CCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient funGradient = LinearGradient(
    colors: [secondary, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient superLikeGradient = LinearGradient(
    colors: [tertiary, Color(0xFF00CCBB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography - rounded and friendly
  static const String fontFamily = 'Nunito';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius - very rounded
  static const double radiusSm = 12.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 28.0;
  static const double radiusXl = 36.0;
  static const double radiusFull = 100.0;

  // Shadows - colorful
  static List<BoxShadow> colorShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // Text styles
  static TextStyle get headline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: text,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: text,
        letterSpacing: -0.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: text,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  // Component decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radiusXl),
        boxShadow: softShadow,
      );

  static BoxDecoration get chipDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusFull),
      );

  static BoxDecoration primaryButtonDecoration(Color color) => BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radiusFull),
        boxShadow: colorShadow(color),
      );
}
