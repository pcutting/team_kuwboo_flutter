import 'package:flutter/material.dart';
import '../../data/color_palettes.dart';
import '../../data/icon_sets.dart';
import '../../prototype/proto_theme.dart';
import 'palette_picker.dart';
import 'icon_set_picker.dart';
import 'route_navigator.dart';

/// Design metadata mirrored from prototype_sidebar.dart.
const _designNames = ['Urban Warmth', 'Dark Mode', 'Organic Warmth', 'Street'];
const _designColors = [Color(0xFFCB6843), Color(0xFF8B5CF6), Color(0xFFCB6843), Color(0xFFE63946)];
const _designIndexMap = [0, 3, 4, 6];

/// Bottom sheet content exposing all developer tools on mobile viewports.
class MobileToolsSheet extends StatefulWidget {
  final int selectedDesign;
  final ValueChanged<int> onDesignSelected;
  final int? paletteIndex;
  final ValueChanged<int?> onPaletteSelected;
  final int? iconSetIndex;
  final ValueChanged<int?> onIconSetSelected;
  final int yoyoVariant;
  final ValueChanged<int> onYoyoVariantChanged;
  final int yoyoMode;
  final ValueChanged<int> onYoyoModeChanged;
  final ValueChanged<String> onNavigateRoute;

  const MobileToolsSheet({
    super.key,
    required this.selectedDesign,
    required this.onDesignSelected,
    required this.paletteIndex,
    required this.onPaletteSelected,
    required this.iconSetIndex,
    required this.onIconSetSelected,
    required this.yoyoVariant,
    required this.onYoyoVariantChanged,
    required this.yoyoMode,
    required this.onYoyoModeChanged,
    required this.onNavigateRoute,
  });

  @override
  State<MobileToolsSheet> createState() => _MobileToolsSheetState();
}

class _MobileToolsSheetState extends State<MobileToolsSheet> {
  bool _paletteExpanded = false;
  bool _iconSetExpanded = false;

  int get _currentOriginalIndex => _designIndexMap[widget.selectedDesign];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle + close button
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Positioned(
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Design variant 2x2 grid
                _sectionLabel('Design Variant'),
                const SizedBox(height: 6),
                _buildDesignGrid(),

                // Palette trigger / inline expand
                const SizedBox(height: 16),
                _sectionLabel('Color Palette'),
                const SizedBox(height: 6),
                _buildPaletteSection(),

                // Icon set trigger / inline expand
                const SizedBox(height: 16),
                _sectionLabel('Icon Set'),
                const SizedBox(height: 6),
                _buildIconSetSection(),

                // YoYo toggles
                const SizedBox(height: 16),
                _sectionLabel('YoYo Controls'),
                const SizedBox(height: 8),
                _buildYoyoToggles(),

                // Route navigator
                const SizedBox(height: 16),
                RouteNavigator(
                  onNavigate: (route) {
                    Navigator.of(context).pop();
                    widget.onNavigateRoute(route);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildDesignGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < _designNames.length; i++)
          _DesignChip(
            name: _designNames[i],
            color: _designColors[i],
            isSelected: i == widget.selectedDesign,
            onTap: () => widget.onDesignSelected(i),
          ),
      ],
    );
  }

  Widget _buildPaletteSection() {
    final paletteName = widget.paletteIndex != null
        ? ColorPalette.visible[widget.paletteIndex!].shortName
        : 'Default';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _paletteExpanded = !_paletteExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    paletteName,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
                Icon(
                  _paletteExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        if (_paletteExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PalettePicker(
              currentDesignIndex: _currentOriginalIndex,
              selectedPaletteIndex: widget.paletteIndex,
              onPaletteSelected: (index) {
                widget.onPaletteSelected(index);
                setState(() => _paletteExpanded = false);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildIconSetSection() {
    final iconName = widget.iconSetIndex != null
        ? ProtoIconSet.all[widget.iconSetIndex!].shortName
        : 'Default';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _iconSetExpanded = !_iconSetExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.style_outlined, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    iconName,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
                Icon(
                  _iconSetExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        if (_iconSetExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: IconSetPicker(
              currentDesignIndex: _currentOriginalIndex,
              selectedIconSetIndex: widget.iconSetIndex,
              onIconSetSelected: (index) {
                widget.onIconSetSelected(index);
                setState(() => _iconSetExpanded = false);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildYoyoToggles() {
    return Column(
      children: [
        _MobileToggle(
          label: 'Version',
          option0: 'V1',
          option1: 'V2 Consent',
          selected: widget.yoyoVariant,
          onChanged: widget.onYoyoVariantChanged,
        ),
        const SizedBox(height: 8),
        _MobileToggle(
          label: 'Mode',
          option0: 'Social',
          option1: 'Inner Circle',
          selected: widget.yoyoMode,
          onChanged: widget.onYoyoModeChanged,
          activeColor1: const Color(0xFFD4A04A),
        ),
      ],
    );
  }
}

// ─── Design Chip (touch-friendly) ──────────────────────────────────────

class _DesignChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesignChip({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 48) / 2;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile Toggle (48px touch targets) ────────────────────────────────

class _MobileToggle extends StatelessWidget {
  final String label;
  final String option0;
  final String option1;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? activeColor1;

  const _MobileToggle({
    required this.label,
    required this.option0,
    required this.option1,
    required this.selected,
    required this.onChanged,
    this.activeColor1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        Expanded(child: _option(option0, 0, null)),
        const SizedBox(width: 6),
        Expanded(child: _option(option1, 1, activeColor1)),
      ],
    );
  }

  Widget _option(String text, int index, Color? activeColor) {
    final isActive = selected == index;
    final color = activeColor;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? (color != null ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.12))
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? (color != null ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.25))
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? (color ?? Colors.white.withValues(alpha: 0.9))
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
