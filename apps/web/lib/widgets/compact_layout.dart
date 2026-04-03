import 'package:flutter/material.dart';
import '../prototype/prototype_app.dart';

/// Compact (mobile) layout — full-screen prototype.
class CompactLayout extends StatelessWidget {
  final int originalDesignIndex;
  final int? paletteIndex;
  final int? iconSetIndex;
  final int yoyoMode;
  final ValueChanged<int> onYoyoModeChanged;

  const CompactLayout({
    super.key,
    required this.originalDesignIndex,
    required this.paletteIndex,
    required this.iconSetIndex,
    required this.yoyoMode,
    required this.onYoyoModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d14),
      body: SafeArea(
        child: PrototypeApp(
          designIndex: originalDesignIndex,
          paletteIndex: paletteIndex,
          iconSetIndex: iconSetIndex,
          yoyoMode: yoyoMode,
          onYoyoModeChanged: onYoyoModeChanged,
        ),
      ),
    );
  }
}
