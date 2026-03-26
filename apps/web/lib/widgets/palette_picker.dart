import 'package:flutter/material.dart';
import '../data/color_palettes.dart';
import '../prototype/proto_theme.dart';

/// A numbered vertical list showing palette options:
/// row 0 = dynamic "design default", then rows 1–N for visible palettes.
/// Each row shows 6 color dots (bg, primary, secondary, accent, tertiary, text).
class PalettePicker extends StatelessWidget {
  final int currentDesignIndex;
  final int? selectedPaletteIndex;
  final ValueChanged<int?> onPaletteSelected;

  const PalettePicker({
    super.key,
    required this.currentDesignIndex,
    required this.selectedPaletteIndex,
    required this.onPaletteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final designTheme = ProtoTheme.fromDesignIndex(currentDesignIndex);
    final palettes = ColorPalette.visible;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              'Color Palette',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Row 0: Design default
          _PaletteRow(
            index: 0,
            name: 'Default',
            colors: [
              designTheme.background,
              designTheme.primary,
              designTheme.secondary,
              designTheme.accent,
              designTheme.tertiary,
              designTheme.text,
            ],
            highlightColor: designTheme.primary,
            isSelected: selectedPaletteIndex == null,
            onTap: () => onPaletteSelected(null),
          ),
          // Rows 1–N: Visible palettes
          for (int i = 0; i < palettes.length; i++)
            _PaletteRow(
              index: i + 1,
              name: palettes[i].name,
              colors: [
                palettes[i].background,
                palettes[i].primary,
                palettes[i].secondary,
                palettes[i].accent,
                palettes[i].tertiary,
                palettes[i].text,
              ],
              highlightColor: palettes[i].primary,
              isSelected: selectedPaletteIndex == i,
              onTap: () => onPaletteSelected(i),
            ),
        ],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final int index;
  final String name;
  final List<Color> colors;
  final Color highlightColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteRow({
    required this.index,
    required this.name,
    required this.colors,
    required this.highlightColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? highlightColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? highlightColor
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Number
            SizedBox(
              width: 24,
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            // 6 color dots
            for (int i = 0; i < colors.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
          ],
        ),
      ),
    );
  }
}
