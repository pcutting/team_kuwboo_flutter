import 'package:flutter/material.dart';
import '../../data/color_palettes.dart';
import '../../prototype/proto_theme.dart';

/// A 4-column grid showing 16 palette options:
/// first cell = dynamic "design default", then 15 swappable palettes.
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Cell 0: Dynamic design default
              _PaletteCell(
                label: 'Default',
                primaryColor: designTheme.primary,
                secondaryColor: designTheme.secondary,
                backgroundColor: designTheme.background,
                isSelected: selectedPaletteIndex == null,
                onTap: () => onPaletteSelected(null),
              ),
              // Cells 1-15: The 15 palettes
              for (int i = 0; i < ColorPalette.visible.length; i++)
                _PaletteCell(
                  label: ColorPalette.visible[i].shortName,
                  primaryColor: ColorPalette.visible[i].primary,
                  secondaryColor: ColorPalette.visible[i].secondary,
                  backgroundColor: ColorPalette.visible[i].background,
                  isSelected: selectedPaletteIndex == i,
                  onTap: () => onPaletteSelected(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaletteCell extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCell({
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color swatch: two circles on a bg square
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
