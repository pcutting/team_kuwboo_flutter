import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Builds a [ThemeData] from the Kuwboo design system tokens.
///
/// Uses the first available [ColorPalette] (Urban Warmth) and wraps
/// it in a standard Material theme so all widgets inherit the brand
/// colors automatically.
class KuwbooTheme {
  KuwbooTheme._();

  static final ColorPalette _palette = ColorPalette.all.first;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _palette.primary,
          primary: _palette.primary,
          secondary: _palette.secondary,
          tertiary: _palette.accent,
          surface: _palette.surface,
        ),
        scaffoldBackgroundColor: _palette.background,
        appBarTheme: AppBarTheme(
          backgroundColor: _palette.background,
          foregroundColor: _palette.text,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _palette.surface,
          selectedItemColor: _palette.primary,
          unselectedItemColor: _palette.textSecondary,
        ),
      );
}
