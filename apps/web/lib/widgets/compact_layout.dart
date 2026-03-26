import 'package:flutter/material.dart';
import '../prototype/prototype_app.dart';

/// Compact (mobile) layout — full-screen prototype with YoYo V1/V2 toggle overlay.
class CompactLayout extends StatelessWidget {
  final int originalDesignIndex;
  final int? paletteIndex;
  final int? iconSetIndex;
  final int yoyoVariant;
  final ValueChanged<int> onYoyoVariantChanged;
  final int yoyoMode;
  final ValueChanged<int> onYoyoModeChanged;

  const CompactLayout({
    super.key,
    required this.originalDesignIndex,
    required this.paletteIndex,
    required this.iconSetIndex,
    required this.yoyoVariant,
    required this.onYoyoVariantChanged,
    required this.yoyoMode,
    required this.onYoyoModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d14),
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen prototype
            Positioned.fill(
              child: PrototypeApp(
                designIndex: originalDesignIndex,
                paletteIndex: paletteIndex,
                iconSetIndex: iconSetIndex,
                yoyoVariant: yoyoVariant,
                onYoyoVariantChanged: onYoyoVariantChanged,
                yoyoMode: yoyoMode,
                onYoyoModeChanged: onYoyoModeChanged,
              ),
            ),
            // Floating V1/V2 toggle (left edge, vertically centered)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _VariantToggle(
                    variant: yoyoVariant,
                    onChanged: onYoyoVariantChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating V1/V2 Toggle ──────────────────────────────────────────────

class _VariantToggle extends StatelessWidget {
  final int variant;
  final ValueChanged<int> onChanged;

  const _VariantToggle({required this.variant, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: 'V1',
            isActive: variant == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(height: 4),
          _TogglePill(
            label: 'V2',
            isActive: variant == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
