import 'package:flutter/material.dart';
import '../data/color_palettes.dart';
import '../data/icon_sets.dart';

// ─── Dark Mode Overrides ─────────────────────────────────────────────────

/// Per-design customizations merged on top of the algorithmic dark transform.
class DarkOverrides {
  final Color? background;
  final Color? surface;
  final Color? text;
  final Color? textSecondary;
  final Color? textTertiary;
  final Color? primary;
  final Color? secondary;
  final Color? accent;
  final Color? tertiary;
  final double? accentPillAlpha;
  final Color? borderColor;
  final Color? glowColor;
  final double? glowAlpha;

  const DarkOverrides({
    this.background,
    this.surface,
    this.text,
    this.textSecondary,
    this.textTertiary,
    this.primary,
    this.secondary,
    this.accent,
    this.tertiary,
    this.accentPillAlpha,
    this.borderColor,
    this.glowColor,
    this.glowAlpha,
  });
}

// ─── HSL Helpers ─────────────────────────────────────────────────────────

HSLColor _toHSL(Color c) => HSLColor.fromColor(c);

Color _adjustHSL(Color c, {double? hue, double? saturation, double? lightness}) {
  final hsl = _toHSL(c);
  return HSLColor.fromAHSL(
    1.0,
    hue ?? hsl.hue,
    (saturation ?? hsl.saturation).clamp(0.0, 1.0),
    (lightness ?? hsl.lightness).clamp(0.0, 1.0),
  ).toColor();
}

/// Boost accent colors for dark backgrounds: +12% saturation, +8% lightness.
Color _boostAccent(Color c) {
  final hsl = _toHSL(c);
  return _adjustHSL(c,
    saturation: hsl.saturation + 0.12,
    lightness: hsl.lightness + 0.08,
  );
}

/// De-boost accent colors for light backgrounds: −10% saturation, −8% lightness.
Color _deBoostAccent(Color c) {
  final hsl = _toHSL(c);
  return _adjustHSL(c,
    saturation: hsl.saturation - 0.10,
    lightness: (hsl.lightness - 0.08).clamp(0.15, 0.85),
  );
}

/// Concrete theme carrying all visual properties used by prototype screens.
/// Each design version has a factory that produces its themed variant.
/// Accessed via `ProtoTheme.of(context)` backed by an InheritedWidget.
class ProtoTheme {
  /// Kuwboo brand red — used for FAB and accent elements.
  static const kuwbooBlue = Color(0xFF1877F2);

  // Colors
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  /// Contrast color for text/icons rendered on primary-colored backgrounds.
  /// White for light themes, near-white for dark themes.
  final Color onPrimary;

  // Semantic colors
  final Color dividerColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color disabledColor;
  final Color overlayColor;

  /// Alias for [text] — aligns with Material's `onSurface` convention.
  Color get onSurface => text;

  // Text styles
  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle label;
  final TextStyle button;

  // Decorations
  final BoxDecoration cardDecoration;
  final BoxDecoration Function(Color) accentPillDecoration;
  final List<BoxShadow> softShadow;
  final List<BoxShadow> warmShadow;

  // Icons
  final ProtoIconSet icons;

  // Other
  final String displayFont;
  final double radiusFull;
  final double radiusLg;
  final double radiusMd;

  ProtoTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    this.onPrimary = Colors.white,
    Color? dividerColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? disabledColor,
    Color? overlayColor,
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.caption,
    required this.label,
    required this.button,
    required this.cardDecoration,
    required this.accentPillDecoration,
    required this.softShadow,
    required this.warmShadow,
    required this.icons,
    required this.displayFont,
    required this.radiusFull,
    required this.radiusLg,
    required this.radiusMd,
  })  : dividerColor = dividerColor ?? text.withValues(alpha: 0.08),
        errorColor = errorColor ?? const Color(0xFFDC3545),
        successColor = successColor ?? const Color(0xFF28A745),
        warningColor = warningColor ?? const Color(0xFFFFC107),
        disabledColor = disabledColor ?? text.withValues(alpha: 0.25),
        overlayColor = overlayColor ?? Colors.black.withValues(alpha: 0.5);

  /// Whether this theme has a dark background.
  bool get isDark => background.computeLuminance() < 0.2;

  /// Retrieve the current ProtoTheme from the widget tree.
  static ProtoTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ProtoThemeProvider>();
    assert(provider != null, 'No ProtoThemeProvider found in context');
    return provider!.theme;
  }

  /// Returns a new ProtoTheme with colors replaced from [palette],
  /// while preserving all structural properties (fonts, sizes, radii, weights).
  ///
  /// Text style color mapping:
  ///   display, button → Colors.white (overlay/primary-bg usage)
  ///   headline, title, label → palette.text
  ///   body → palette.textSecondary
  ///   caption → palette.textTertiary
  ProtoTheme withPalette(ColorPalette palette) {
    return ProtoTheme(
      // Colors — all from palette
      primary: palette.primary,
      secondary: palette.secondary,
      accent: palette.accent,
      tertiary: palette.tertiary,
      background: palette.background,
      surface: palette.surface,
      text: palette.text,
      textSecondary: palette.textSecondary,
      textTertiary: palette.textTertiary,
      // Text styles — same font/size/weight, recolored
      display: display.copyWith(color: Colors.white),
      headline: headline.copyWith(color: palette.text),
      title: title.copyWith(color: palette.text),
      body: body.copyWith(color: palette.textSecondary),
      caption: caption.copyWith(color: palette.textTertiary),
      label: label.copyWith(color: palette.text),
      button: button.copyWith(color: Colors.white),
      // Decorations — surface color + preserved shadow structure
      cardDecoration: BoxDecoration(
        color: palette.surface,
        borderRadius: cardDecoration.borderRadius,
        border: cardDecoration.border,
        boxShadow: cardDecoration.boxShadow?.map((s) =>
          BoxShadow(
            color: palette.text.withValues(alpha: s.color.a),
            blurRadius: s.blurRadius,
            spreadRadius: s.spreadRadius,
            offset: s.offset,
          ),
        ).toList(),
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: accentPillDecoration(color).borderRadius,
      ),
      softShadow: softShadow.map((s) =>
        BoxShadow(
          color: palette.text.withValues(alpha: s.color.a),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          offset: s.offset,
        ),
      ).toList(),
      warmShadow: warmShadow.map((s) =>
        BoxShadow(
          color: palette.primary.withValues(alpha: s.color.a),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          offset: s.offset,
        ),
      ).toList(),
      // Semantic — derived from palette
      dividerColor: palette.text.withValues(alpha: palette.isDark ? 0.12 : 0.08),
      errorColor: errorColor,
      successColor: successColor,
      warningColor: warningColor,
      disabledColor: palette.text.withValues(alpha: palette.isDark ? 0.30 : 0.25),
      overlayColor: Colors.black.withValues(alpha: palette.isDark ? 0.6 : 0.5),
      // Icons — preserved as-is
      icons: icons,
      // Structural — preserved as-is
      displayFont: displayFont,
      radiusFull: radiusFull,
      radiusLg: radiusLg,
      radiusMd: radiusMd,
    );
  }

  /// Returns a new ProtoTheme with icons replaced from [iconSet],
  /// while preserving all other properties (colors, fonts, sizes, radii).
  ProtoTheme withIconSet(ProtoIconSet iconSet) {
    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      dividerColor: dividerColor,
      errorColor: errorColor,
      successColor: successColor,
      warningColor: warningColor,
      disabledColor: disabledColor,
      overlayColor: overlayColor,
      display: display,
      headline: headline,
      title: title,
      body: body,
      caption: caption,
      label: label,
      button: button,
      cardDecoration: cardDecoration,
      accentPillDecoration: accentPillDecoration,
      softShadow: softShadow,
      warmShadow: warmShadow,
      icons: iconSet,
      displayFont: displayFont,
      radiusFull: radiusFull,
      radiusLg: radiusLg,
      radiusMd: radiusMd,
    );
  }

  // ─── Dark Mode Per-Design Overrides ──────────────────────────────────

  static const Map<int, DarkOverrides> _darkOverrides = {
    // V0 Urban Warmth → Warm charcoal with amber glow
    0: DarkOverrides(
      background: Color(0xFF1A1410),
      surface: Color(0xFF241E18),
      text: Color(0xFFF5EDE6),
      textSecondary: Color(0xFFB8A898),
      textTertiary: Color(0xFF8A7B6B),
      glowColor: Color(0xFFCB6843),
      glowAlpha: 0.30,
    ),
    // V2 Soft Luxury → Rich dark brown with gold glow
    1: DarkOverrides(
      background: Color(0xFF141210),
      surface: Color(0xFF1E1A16),
      text: Color(0xFFF5F0EA),
      textSecondary: Color(0xFFB8ADA0),
      textTertiary: Color(0xFF8A7F72),
      glowColor: Color(0xFFB8956F),
      glowAlpha: 0.25,
    ),
    // V3 Vibrant Pop → Near-black navy (neons already saturated — no boost)
    2: DarkOverrides(
      background: Color(0xFF0A0A14),
      surface: Color(0xFF12121E),
      text: Color(0xFFF5F5FF),
      textSecondary: Color(0xFFB0B0C8),
      textTertiary: Color(0xFF6B6B8D),
    ),
    // V4 Dark Mode Native — handled by toLight(), not toDark()
    // V5 Organic Warmth → Earthy dark with terracotta glow
    4: DarkOverrides(
      background: Color(0xFF18140E),
      surface: Color(0xFF221C14),
      text: Color(0xFFF5EDE4),
      textSecondary: Color(0xFFB8A898),
      textTertiary: Color(0xFF8A7B6B),
      glowColor: Color(0xFFCB6843),
      glowAlpha: 0.25,
    ),
    // V6 Minimal Swiss → Stark black, no glow (brutalist), border-only
    5: DarkOverrides(
      background: Color(0xFF0A0A0A),
      surface: Color(0xFF141414),
      text: Color(0xFFF5F5F5),
      textSecondary: Color(0xFFAAAAAA),
      textTertiary: Color(0xFF777777),
      borderColor: Color(0xFF333333),
    ),
    // V9 Hyper-Local Street → Urban dark with red glow
    6: DarkOverrides(
      background: Color(0xFF121210),
      surface: Color(0xFF1C1C18),
      text: Color(0xFFF5F2EB),
      textSecondary: Color(0xFFB0AAA0),
      textTertiary: Color(0xFF7A7A70),
      glowColor: Color(0xFFE63946),
      glowAlpha: 0.30,
    ),
    // V10 Calm Tech → Muted deep with subtle lavender glow
    7: DarkOverrides(
      background: Color(0xFF0E0D14),
      surface: Color(0xFF16151E),
      text: Color(0xFFF0EEF5),
      textSecondary: Color(0xFFADA8B8),
      textTertiary: Color(0xFF7A7588),
      glowColor: Color(0xFFA78BFA),
      glowAlpha: 0.20,
    ),
  };

  // ─── V4 Streetlight (Light Companion) ──────────────────────────────────

  /// Transforms V4's native dark palette into a light "Streetlight" variant.
  /// Preserves V4's purple/cyan identity on a cool lavender background.
  ProtoTheme toLight() {
    if (!isDark) return this;

    const bg = Color(0xFFF5F3FF);
    const surf = Color(0xFFFFFFFF);
    const txt = Color(0xFF1A1A2E);
    const txtSec = Color(0xFF555570);
    const txtTer = Color(0xFF8888A0);
    final pri = _deBoostAccent(primary);
    final sec = _deBoostAccent(secondary);
    final acc = _deBoostAccent(accent);
    final ter = _deBoostAccent(tertiary);

    return ProtoTheme(
      primary: pri,
      secondary: sec,
      accent: acc,
      tertiary: ter,
      background: bg,
      surface: surf,
      text: txt,
      textSecondary: txtSec,
      textTertiary: txtTer,
      onPrimary: Colors.white,
      display: display.copyWith(color: Colors.white),
      headline: headline.copyWith(color: txt),
      title: title.copyWith(color: txt),
      body: body.copyWith(color: txtSec),
      caption: caption.copyWith(color: txtTer),
      label: label.copyWith(color: txt),
      button: button.copyWith(color: Colors.white),
      cardDecoration: BoxDecoration(
        color: surf,
        borderRadius: cardDecoration.borderRadius,
        boxShadow: [BoxShadow(color: txt.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: accentPillDecoration(color).borderRadius,
      ),
      softShadow: [BoxShadow(color: txt.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      warmShadow: [BoxShadow(color: pri.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      dividerColor: txt.withValues(alpha: 0.08),
      errorColor: const Color(0xFFDC3545),
      successColor: const Color(0xFF28A745),
      warningColor: const Color(0xFFFFC107),
      disabledColor: txt.withValues(alpha: 0.25),
      overlayColor: Colors.black.withValues(alpha: 0.5),
      icons: icons,
      displayFont: displayFont,
      radiusFull: radiusFull,
      radiusLg: radiusLg,
      radiusMd: radiusMd,
    );
  }

  // ─── toDark() — Algorithmic + Per-Design Overrides ─────────────────────

  /// Transforms this light theme into a dark variant. Applies HSL-based
  /// algorithmic defaults, then merges any per-design [DarkOverrides].
  ///
  /// For already-dark themes (e.g. V4), returns `this` unchanged.
  /// Pass [designIndex] to apply per-design personality overrides.
  ProtoTheme toDark({int? designIndex}) {
    // Already dark — no-op (V4 uses toLight() for the inverse direction)
    if (isDark) return this;

    final overrides = designIndex != null ? _darkOverrides[designIndex] : null;

    // ── Colors ──────────────────────────────────────────────────────────
    final hsl = _toHSL(background);

    final darkBg = overrides?.background ?? _adjustHSL(
      background,
      saturation: hsl.saturation * 0.8,
      lightness: 0.06,
    );
    final darkSurf = overrides?.surface ?? _adjustHSL(
      background,
      saturation: hsl.saturation * 0.6,
      lightness: 0.10,
    );

    // Text: near-white preserving hue warmth
    final textHsl = _toHSL(text);
    final darkText = overrides?.text ?? _adjustHSL(
      text,
      saturation: textHsl.saturation * 0.3,
      lightness: 0.92,
    );
    final darkTextSec = overrides?.textSecondary ?? _adjustHSL(
      textSecondary,
      saturation: _toHSL(textSecondary).saturation * 0.4,
      lightness: 0.65,
    );
    final darkTextTer = overrides?.textTertiary ?? _adjustHSL(
      textTertiary,
      saturation: _toHSL(textTertiary).saturation * 0.4,
      lightness: 0.45,
    );

    // Accents: boost saturation/lightness for pop on dark bg
    final darkPri = overrides?.primary ?? _boostAccent(primary);
    final darkSec = overrides?.secondary ?? _boostAccent(secondary);
    final darkAcc = overrides?.accent ?? _boostAccent(accent);
    final darkTer = overrides?.tertiary ?? _boostAccent(tertiary);

    // ── Shadows → Glows ────────────────────────────────────────────────
    final glowColor = overrides?.glowColor ?? darkPri;
    final glowAlpha = overrides?.glowAlpha ?? 0.25;

    final darkSoftShadow = [
      BoxShadow(
        color: glowColor.withValues(alpha: glowAlpha * 0.6),
        blurRadius: 12,
        // Zero offset — ambient glow, not directional shadow
      ),
    ];

    final darkWarmShadow = [
      BoxShadow(
        color: glowColor.withValues(alpha: glowAlpha),
        blurRadius: 20,
      ),
    ];

    // ── Card: border replaces shadow on dark bg ────────────────────────
    final borderColor = overrides?.borderColor ??
        darkText.withValues(alpha: 0.10);
    final darkCardDecoration = BoxDecoration(
      color: darkSurf,
      borderRadius: cardDecoration.borderRadius,
      border: Border.all(color: borderColor),
    );

    // ── Accent pills: higher alpha on dark bg ──────────────────────────
    final pillAlpha = overrides?.accentPillAlpha ?? 0.22;

    return ProtoTheme(
      primary: darkPri,
      secondary: darkSec,
      accent: darkAcc,
      tertiary: darkTer,
      background: darkBg,
      surface: darkSurf,
      text: darkText,
      textSecondary: darkTextSec,
      textTertiary: darkTextTer,
      onPrimary: Colors.white,
      display: display.copyWith(color: Colors.white),
      headline: headline.copyWith(color: darkText),
      title: title.copyWith(color: darkText),
      body: body.copyWith(color: darkTextSec),
      caption: caption.copyWith(color: darkTextTer),
      label: label.copyWith(color: darkText),
      button: button.copyWith(color: Colors.white),
      cardDecoration: darkCardDecoration,
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: pillAlpha),
        borderRadius: accentPillDecoration(color).borderRadius,
      ),
      softShadow: darkSoftShadow,
      warmShadow: darkWarmShadow,
      dividerColor: darkText.withValues(alpha: 0.12),
      errorColor: _boostAccent(errorColor),
      successColor: _boostAccent(successColor),
      warningColor: _boostAccent(warningColor),
      disabledColor: darkText.withValues(alpha: 0.30),
      overlayColor: Colors.black.withValues(alpha: 0.6),
      icons: icons,
      displayFont: displayFont,
      radiusFull: radiusFull,
      radiusLg: radiusLg,
      radiusMd: radiusMd,
    );
  }

  /// Map a design index (0-7) to the correct factory.
  static ProtoTheme fromDesignIndex(int index) {
    switch (index) {
      case 0:
        return v0UrbanWarmth();
      case 1:
        return v2SoftLuxury();
      case 2:
        return v3VibrantPop();
      case 3:
        return v4DarkModeNative();
      case 4:
        return v5OrganicWarmth();
      case 5:
        return v6MinimalSwiss();
      case 6:
        return v9HyperLocalStreet();
      case 7:
        return v10CalmTech();
      default:
        return v0UrbanWarmth();
    }
  }

  // ─── V0: Urban Warmth ─────────────────────────────────────────────────

  static ProtoTheme v0UrbanWarmth() {
    const primary = Color(0xFFCB6843);
    const secondary = Color(0xFF7B9E6B);
    const accent = Color(0xFFD4453C);
    const tertiary = Color(0xFFF4A460);
    const background = Color(0xFFF8F4F0);
    const surface = Color(0xFFFFFFFF);
    const text = Color(0xFF2D2A26);
    const textSec = Color(0xFF5A4E43);
    const textTer = Color(0xFF7A6E62);
    const displayFont = 'Bebas Neue';
    const bodyFont = 'Lato';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: displayFont, fontSize: 44, fontWeight: FontWeight.w400,
        color: Colors.white, letterSpacing: 2, height: 0.95,
      ),
      headline: const TextStyle(
        fontFamily: displayFont, fontSize: 32, fontWeight: FontWeight.w400,
        color: text, letterSpacing: 1, height: 1.0,
      ),
      title: const TextStyle(
        fontFamily: bodyFont, fontSize: 16, fontWeight: FontWeight.w600,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: bodyFont, fontSize: 14, fontWeight: FontWeight.w400,
        color: textSec, height: 1.5,
      ),
      caption: const TextStyle(
        fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w500,
        color: textTer,
      ),
      label: const TextStyle(
        fontFamily: displayFont, fontSize: 12, fontWeight: FontWeight.w400,
        color: text, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: displayFont, fontSize: 16, fontWeight: FontWeight.w400,
        color: surface, letterSpacing: 1,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: text.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: displayFont,
      radiusFull: 100,
      radiusLg: 24,
      radiusMd: 16,
    );
  }

  // ─── V2: Soft Luxury ──────────────────────────────────────────────────

  static ProtoTheme v2SoftLuxury() {
    const primary = Color(0xFFB8956F);
    const secondary = Color(0xFF722F37);
    const background = Color(0xFFFAF8F5);
    const surface = Color(0xFFFFFFFF);
    const text = Color(0xFF2D2926);
    const textSec = Color(0xFF5A5550);
    const textTer = Color(0xFF7A746E);
    const serifFont = 'Playfair Display';
    const sansFont = 'Inter';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: secondary.withValues(alpha: 0.7),
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: serifFont, fontSize: 44, fontWeight: FontWeight.w500,
        color: Colors.white, letterSpacing: -0.5, height: 1.1,
      ),
      headline: const TextStyle(
        fontFamily: serifFont, fontSize: 32, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.5, height: 1.2,
      ),
      title: const TextStyle(
        fontFamily: sansFont, fontSize: 16, fontWeight: FontWeight.w500,
        color: text, height: 1.4,
      ),
      body: const TextStyle(
        fontFamily: sansFont, fontSize: 15, fontWeight: FontWeight.w400,
        color: textSec, height: 1.6,
      ),
      caption: const TextStyle(
        fontFamily: sansFont, fontSize: 12, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 0.5,
      ),
      label: const TextStyle(
        fontFamily: sansFont, fontSize: 11, fontWeight: FontWeight.w600,
        color: textTer, letterSpacing: 1.2,
      ),
      button: const TextStyle(
        fontFamily: sansFont, fontSize: 14, fontWeight: FontWeight.w500,
        color: surface, letterSpacing: 0.3,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: text.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: serifFont,
      radiusFull: 100,
      radiusLg: 20,
      radiusMd: 12,
    );
  }

  // ─── V3: Vibrant Pop ──────────────────────────────────────────────────

  static ProtoTheme v3VibrantPop() {
    const primary = Color(0xFF0066FF);
    const secondary = Color(0xFFFF0080);
    const tertiary = Color(0xFF00FF88);
    const accent = Color(0xFFFF6600);
    const background = Color(0xFFFFFFFF);
    const surface = Color(0xFFF8F8FF);
    const text = Color(0xFF1A1A2E);
    const textSec = Color(0xFF6B6B8D);
    const font = 'Nunito';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textSec,
      display: const TextStyle(
        fontFamily: font, fontSize: 44, fontWeight: FontWeight.w800,
        color: Colors.white, letterSpacing: -0.5, height: 1.0,
      ),
      headline: const TextStyle(
        fontFamily: font, fontSize: 32, fontWeight: FontWeight.w800,
        color: text, letterSpacing: -0.5, height: 1.1,
      ),
      title: const TextStyle(
        fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: font, fontSize: 15, fontWeight: FontWeight.w500,
        color: textSec, height: 1.5,
      ),
      caption: const TextStyle(
        fontFamily: font, fontSize: 12, fontWeight: FontWeight.w600,
        color: textSec,
      ),
      label: const TextStyle(
        fontFamily: font, fontSize: 12, fontWeight: FontWeight.w600,
        color: text, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: 0.3,
      ),
      cardDecoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [BoxShadow(color: text.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: font,
      radiusFull: 100,
      radiusLg: 28,
      radiusMd: 20,
    );
  }

  // ─── V4: Dark Mode Native ─────────────────────────────────────────────

  static ProtoTheme v4DarkModeNative() {
    const primary = Color(0xFF8B5CF6);
    const secondary = Color(0xFF06B6D4);
    const tertiary = Color(0xFFEC4899);
    const background = Color(0xFF000000);
    const surface = Color(0xFF0A0A0F);
    const text = Color(0xFFFFFFFF);
    const textSec = Color(0xFF9CA3AF);
    const textTer = Color(0xFF6B7280);
    const font = 'Inter';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: font, fontSize: 44, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: -0.5, height: 1.0,
      ),
      headline: const TextStyle(
        fontFamily: font, fontSize: 28, fontWeight: FontWeight.w700,
        color: text, letterSpacing: -0.5, height: 1.2,
      ),
      title: const TextStyle(
        fontFamily: font, fontSize: 15, fontWeight: FontWeight.w600,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: font, fontSize: 14, fontWeight: FontWeight.w400,
        color: textSec, height: 1.5,
      ),
      caption: const TextStyle(
        fontFamily: font, fontSize: 11, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 0.5,
      ),
      label: const TextStyle(
        fontFamily: font, fontSize: 12, fontWeight: FontWeight.w500,
        color: text, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: font, fontSize: 14, fontWeight: FontWeight.w600,
        color: text,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F28)),
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      softShadow: [BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 12)],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 20)],
      icons: ProtoIconSet.appleHIG,
      displayFont: font,
      radiusFull: 100,
      radiusLg: 24,
      radiusMd: 12,
    );
  }

  // ─── V5: Organic Warmth ───────────────────────────────────────────────

  static ProtoTheme v5OrganicWarmth() {
    const primary = Color(0xFFCB6843);
    const secondary = Color(0xFF7B9E6B);
    const tertiary = Color(0xFFF4A460);
    const background = Color(0xFFFDF8F4);
    const surface = Color(0xFFFFFFFF);
    const text = Color(0xFF3D3229);
    const textSec = Color(0xFF5A4E43);
    const textTer = Color(0xFF7A6E62);
    const displayFont = 'Playfair Display';
    const bodyFont = 'Lato';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: displayFont, fontSize: 44, fontWeight: FontWeight.w500,
        color: Colors.white, letterSpacing: -0.5, height: 1.1,
      ),
      headline: const TextStyle(
        fontFamily: displayFont, fontSize: 30, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.5, height: 1.2,
      ),
      title: const TextStyle(
        fontFamily: bodyFont, fontSize: 16, fontWeight: FontWeight.w600,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: bodyFont, fontSize: 15, fontWeight: FontWeight.w400,
        color: textSec, height: 1.6,
      ),
      caption: const TextStyle(
        fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w500,
        color: textTer,
      ),
      label: const TextStyle(
        fontFamily: displayFont, fontSize: 12, fontWeight: FontWeight.w400,
        color: text, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: bodyFont, fontSize: 15, fontWeight: FontWeight.w600,
        color: surface,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: text.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(40),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: displayFont,
      radiusFull: 100,
      radiusLg: 28,
      radiusMd: 20,
    );
  }

  // ─── V6: Minimal Swiss ────────────────────────────────────────────────

  static ProtoTheme v6MinimalSwiss() {
    const primary = Color(0xFFE53935);
    const secondary = Color(0xFF1976D2);
    const background = Color(0xFFFFFFFF);
    const surface = Color(0xFFFAFAFA);
    const text = Color(0xFF000000);
    const textSec = Color(0xFF666666);
    const textTer = Color(0xFF999999);
    const font = 'Helvetica Neue';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: secondary.withValues(alpha: 0.7),
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: font, fontSize: 44, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: -1.5, height: 1.0,
      ),
      headline: const TextStyle(
        fontFamily: font, fontSize: 36, fontWeight: FontWeight.w700,
        color: text, letterSpacing: -1.5, height: 1.1,
      ),
      title: const TextStyle(
        fontFamily: font, fontSize: 14, fontWeight: FontWeight.w500,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: font, fontSize: 14, fontWeight: FontWeight.w400,
        color: textSec, height: 1.6,
      ),
      caption: const TextStyle(
        fontFamily: font, fontSize: 11, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 0.5,
      ),
      label: const TextStyle(
        fontFamily: font, fontSize: 10, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: font, fontSize: 13, fontWeight: FontWeight.w500,
        color: background, letterSpacing: 0.5,
      ),
      cardDecoration: const BoxDecoration(color: background),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
      softShadow: const [],
      warmShadow: const [],
      icons: ProtoIconSet.appleHIG,
      displayFont: font,
      radiusFull: 100,
      radiusLg: 4,
      radiusMd: 4,
    );
  }

  // ─── V9: Hyper-Local Street ───────────────────────────────────────────

  static ProtoTheme v9HyperLocalStreet() {
    const primary = Color(0xFFE63946);
    const secondary = Color(0xFF457B9D);
    const tertiary = Color(0xFFF4A261);
    const background = Color(0xFFF5F1EB);
    const surface = Color(0xFFFFFFFF);
    const text = Color(0xFF1D1D1D);
    const textSec = Color(0xFF4A4A4A);
    const textTer = Color(0xFF686868);
    const condensedFont = 'Bebas Neue';
    const bodyFont = 'Inter';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: condensedFont, fontSize: 48, fontWeight: FontWeight.w400,
        color: Colors.white, letterSpacing: 2, height: 0.9,
      ),
      headline: const TextStyle(
        fontFamily: condensedFont, fontSize: 32, fontWeight: FontWeight.w400,
        color: text, letterSpacing: 1, height: 1.0,
      ),
      title: const TextStyle(
        fontFamily: bodyFont, fontSize: 14, fontWeight: FontWeight.w600,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: bodyFont, fontSize: 14, fontWeight: FontWeight.w400,
        color: textSec, height: 1.5,
      ),
      caption: const TextStyle(
        fontFamily: condensedFont, fontSize: 12, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 1,
      ),
      label: const TextStyle(
        fontFamily: condensedFont, fontSize: 11, fontWeight: FontWeight.w400,
        color: text, letterSpacing: 1.5,
      ),
      button: const TextStyle(
        fontFamily: condensedFont, fontSize: 16, fontWeight: FontWeight.w400,
        color: surface, letterSpacing: 1,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        boxShadow: [BoxShadow(color: text.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(2, 2))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(2, 2))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: condensedFont,
      radiusFull: 100,
      radiusLg: 8,
      radiusMd: 8,
    );
  }

  // ─── V10: Calm Tech ───────────────────────────────────────────────────

  static ProtoTheme v10CalmTech() {
    const primary = Color(0xFFA78BFA);
    const secondary = Color(0xFF86EFAC);
    const tertiary = Color(0xFFFDA4AF);
    const background = Color(0xFFF8F7FF);
    const surface = Color(0xFFFFFFFF);
    const text = Color(0xFF374151);
    const textSec = Color(0xFF555E6E);
    const textTer = Color(0xFF7E8694);
    const font = 'DM Sans';

    return ProtoTheme(
      primary: primary,
      secondary: secondary,
      accent: primary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSec,
      textTertiary: textTer,
      display: const TextStyle(
        fontFamily: font, fontSize: 44, fontWeight: FontWeight.w600,
        color: Colors.white, letterSpacing: -0.5, height: 1.0,
      ),
      headline: const TextStyle(
        fontFamily: font, fontSize: 28, fontWeight: FontWeight.w600,
        color: text, letterSpacing: -0.5, height: 1.2,
      ),
      title: const TextStyle(
        fontFamily: font, fontSize: 15, fontWeight: FontWeight.w500,
        color: text,
      ),
      body: const TextStyle(
        fontFamily: font, fontSize: 15, fontWeight: FontWeight.w400,
        color: textSec, height: 1.6,
      ),
      caption: const TextStyle(
        fontFamily: font, fontSize: 12, fontWeight: FontWeight.w500,
        color: textTer,
      ),
      label: const TextStyle(
        fontFamily: font, fontSize: 11, fontWeight: FontWeight.w500,
        color: textTer, letterSpacing: 0.5,
      ),
      button: const TextStyle(
        fontFamily: font, fontSize: 15, fontWeight: FontWeight.w500,
        color: surface,
      ),
      cardDecoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      accentPillDecoration: (color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      softShadow: [BoxShadow(color: text.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      warmShadow: [BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
      icons: ProtoIconSet.appleHIG,
      displayFont: font,
      radiusFull: 100,
      radiusLg: 24,
      radiusMd: 16,
    );
  }
}

/// InheritedWidget that provides [ProtoTheme] to the prototype subtree.
class ProtoThemeProvider extends InheritedWidget {
  final ProtoTheme theme;

  const ProtoThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  @override
  bool updateShouldNotify(ProtoThemeProvider oldWidget) =>
      !identical(theme, oldWidget.theme);
}
