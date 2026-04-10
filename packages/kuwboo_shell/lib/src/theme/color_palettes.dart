import 'package:flutter/material.dart';

/// A swappable color palette that can override any design's colors
/// while preserving its structural properties (fonts, sizes, radii).
class ColorPalette {
  final String name;
  final String shortName;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  const ColorPalette({
    required this.name,
    required this.shortName,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
  });

  /// Whether this palette uses a dark background.
  bool get isDark {
    final lum = background.computeLuminance();
    return lum < 0.2;
  }

  /// Palette names to hide from the viewer (Neil's feedback Feb 26).
  /// Kept: Sunset Boulevard, Coral Reef, Golden Hour, Sahara Dusk
  static const _hiddenPaletteNames = {
    'Ocean Depths',
    'Nordic Frost',
    'Rose Quartz',
    'Forest Canopy',
    'Slate Professional',
    'Midnight Purple',
    'Neon Tokyo',
    'Electric Violet',
  };

  /// Only the palettes Neil approved (warm 4).
  static List<ColorPalette> get visible =>
      all.where((p) => !_hiddenPaletteNames.contains(p.name)).toList();

  static const List<ColorPalette> all = [
    // Sunset Boulevard — Warm orange/red (Light)
    ColorPalette(
      name: 'Sunset Boulevard',
      shortName: 'Sunset',
      primary: Color(0xFFE85D04),
      secondary: Color(0xFFDC2F02),
      accent: Color(0xFFF48C06),
      tertiary: Color(0xFFFFBA08),
      background: Color(0xFFFFF5EE),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3D1C00),
      textSecondary: Color(0xFF5A3818),
      textTertiary: Color(0xFF7A6145),
    ),

    // Coral Reef — Warm pinks (Light)
    ColorPalette(
      name: 'Coral Reef',
      shortName: 'Coral',
      primary: Color(0xFFE07A5F),
      secondary: Color(0xFF81B29A),
      accent: Color(0xFFF2CC8F),
      tertiary: Color(0xFF3D405B),
      background: Color(0xFFFFF8F6),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3D2B24),
      textSecondary: Color(0xFF5A453D),
      textTertiary: Color(0xFF7A6A63),
    ),

    // Golden Hour — Golds/ambers (Light)
    ColorPalette(
      name: 'Golden Hour',
      shortName: 'Golden',
      primary: Color(0xFFD4A373),
      secondary: Color(0xFFA47148),
      accent: Color(0xFFE9C46A),
      tertiary: Color(0xFF264653),
      background: Color(0xFFFFFCF5),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3A2E1F),
      textSecondary: Color(0xFF5A4D3D),
      textTertiary: Color(0xFF7A6E5F),
    ),

    // Sahara Dusk — Desert earth tones (Light)
    ColorPalette(
      name: 'Sahara Dusk',
      shortName: 'Sahara',
      primary: Color(0xFFB07D62),
      secondary: Color(0xFF8B6914),
      accent: Color(0xFFD4A76A),
      tertiary: Color(0xFF5C4033),
      background: Color(0xFFFBF7F2),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3D2B1F),
      textSecondary: Color(0xFF5A4738),
      textTertiary: Color(0xFF7A6D5D),
    ),

    // ── Cool & Professional ───────────────────────────────────────────

    // Ocean Depths — Deep blues and teals (Light)
    ColorPalette(
      name: 'Ocean Depths',
      shortName: 'Ocean',
      primary: Color(0xFF0077B6),
      secondary: Color(0xFF00B4D8),
      accent: Color(0xFF48CAE4),
      tertiary: Color(0xFF023E8A),
      background: Color(0xFFF0F7FA),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF0A1628),
      textSecondary: Color(0xFF3A5068),
      textTertiary: Color(0xFF6B8A9E),
    ),

    // Nordic Frost — Ice blues and cool grays (Light)
    ColorPalette(
      name: 'Nordic Frost',
      shortName: 'Nordic',
      primary: Color(0xFF5E81AC),
      secondary: Color(0xFF81A1C1),
      accent: Color(0xFF88C0D0),
      tertiary: Color(0xFF4C566A),
      background: Color(0xFFECEFF4),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF2E3440),
      textSecondary: Color(0xFF4C566A),
      textTertiary: Color(0xFF7B88A1),
    ),

    // Rose Quartz — Soft pinks and mauves (Light)
    ColorPalette(
      name: 'Rose Quartz',
      shortName: 'Rose',
      primary: Color(0xFFDB7093),
      secondary: Color(0xFFB56576),
      accent: Color(0xFFE8A0BF),
      tertiary: Color(0xFF6D3B47),
      background: Color(0xFFFFF0F5),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3D1F2B),
      textSecondary: Color(0xFF6B4A55),
      textTertiary: Color(0xFF9A7A85),
    ),

    // Forest Canopy — Rich greens (Light)
    ColorPalette(
      name: 'Forest Canopy',
      shortName: 'Forest',
      primary: Color(0xFF2D6A4F),
      secondary: Color(0xFF40916C),
      accent: Color(0xFF52B788),
      tertiary: Color(0xFF1B4332),
      background: Color(0xFFF0F7F4),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF1A2E23),
      textSecondary: Color(0xFF3D5C4A),
      textTertiary: Color(0xFF6B8A78),
    ),

    // Slate Professional — Cool grays and blue-steel (Light)
    ColorPalette(
      name: 'Slate Professional',
      shortName: 'Slate',
      primary: Color(0xFF475569),
      secondary: Color(0xFF64748B),
      accent: Color(0xFF3B82F6),
      tertiary: Color(0xFF1E293B),
      background: Color(0xFFF1F5F9),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
      textTertiary: Color(0xFF94A3B8),
    ),

    // ── Dark Palettes ─────────────────────────────────────────────────

    // Midnight Purple — Deep violet (Dark)
    ColorPalette(
      name: 'Midnight Purple',
      shortName: 'Midnight',
      primary: Color(0xFFA855F7),
      secondary: Color(0xFF7C3AED),
      accent: Color(0xFFC084FC),
      tertiary: Color(0xFF6D28D9),
      background: Color(0xFF0F0A1A),
      surface: Color(0xFF1A1228),
      text: Color(0xFFF5F0FF),
      textSecondary: Color(0xFFB8A5D4),
      textTertiary: Color(0xFF7C6A9A),
    ),

    // Neon Tokyo — Bright neons on dark (Dark)
    ColorPalette(
      name: 'Neon Tokyo',
      shortName: 'Neon',
      primary: Color(0xFFFF006E),
      secondary: Color(0xFF00F5D4),
      accent: Color(0xFFFFBE0B),
      tertiary: Color(0xFF8338EC),
      background: Color(0xFF0A0A12),
      surface: Color(0xFF14141F),
      text: Color(0xFFF5F5FF),
      textSecondary: Color(0xFFB0B0C8),
      textTertiary: Color(0xFF6B6B88),
    ),

    // Electric Violet — Bold purple on dark (Dark)
    ColorPalette(
      name: 'Electric Violet',
      shortName: 'Electric',
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF22D3EE),
      accent: Color(0xFFA78BFA),
      tertiary: Color(0xFFF472B6),
      background: Color(0xFF0C0C1D),
      surface: Color(0xFF161630),
      text: Color(0xFFF0EEFF),
      textSecondary: Color(0xFFADA8D4),
      textTertiary: Color(0xFF6B669A),
    ),
  ];
}
