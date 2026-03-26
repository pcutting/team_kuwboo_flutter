import 'package:flutter/material.dart';
import '../data/icon_sets.dart';
import '../prototype/proto_theme.dart';

/// A grid showing 5 icon set options:
/// first cell = dynamic "design default", then 4 swappable icon sets.
class IconSetPicker extends StatelessWidget {
  final int currentDesignIndex;
  final int? selectedIconSetIndex;
  final ValueChanged<int?> onIconSetSelected;

  const IconSetPicker({
    super.key,
    required this.currentDesignIndex,
    required this.selectedIconSetIndex,
    required this.onIconSetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              'Icon Set',
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
              _IconSetCell(
                label: 'V${currentDesignIndex + 1} Default',
                iconSet: ProtoIconSet.modernOutlined,
                isSelected: selectedIconSetIndex == null,
                onTap: () => onIconSetSelected(null),
              ),
              // Cells 1-4: The 4 icon sets
              for (int i = 0; i < ProtoIconSet.all.length; i++)
                _IconSetCell(
                  label: ProtoIconSet.all[i].shortName,
                  iconSet: ProtoIconSet.all[i],
                  isSelected: selectedIconSetIndex == i,
                  onTap: () => onIconSetSelected(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconSetCell extends StatelessWidget {
  final String label;
  final ProtoIconSet iconSet;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconSetCell({
    required this.label,
    required this.iconSet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewColor = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2x2 icon preview grid
            SizedBox(
              width: 40,
              height: 40,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: [
                  Icon(iconSet.favoriteFilled, size: 16, color: previewColor),
                  Icon(iconSet.share, size: 16, color: previewColor),
                  Icon(iconSet.search, size: 16, color: previewColor),
                  Icon(iconSet.chatBubbleOutline, size: 16, color: previewColor),
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
