import 'package:flutter/material.dart';
import '../../data/color_palettes.dart';
import '../../data/icon_sets.dart';
import 'palette_picker.dart';
import 'icon_set_picker.dart';
import 'route_navigator.dart';

/// Metadata for the 4 visible designs (hardcoded to avoid importing DesignRegistry).
class _DesignInfo {
  final String name;
  final String shortName;
  final int originalIndex;
  final Color primaryColor;
  const _DesignInfo(this.name, this.shortName, this.originalIndex, this.primaryColor);
}

const _visibleDesigns = [
  _DesignInfo('Urban Warmth', 'Warmth', 0, Color(0xFFCB6843)),
  _DesignInfo('Dark Mode', 'Dark', 3, Color(0xFF8B5CF6)),
  _DesignInfo('Organic Warmth', 'Organic', 4, Color(0xFFCB6843)),
  _DesignInfo('Street', 'Street', 6, Color(0xFFE63946)),
];

class PrototypeSidebar extends StatefulWidget {
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

  const PrototypeSidebar({
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
  State<PrototypeSidebar> createState() => _PrototypeSidebarState();
}

class _PrototypeSidebarState extends State<PrototypeSidebar> {
  final LayerLink _paletteLink = LayerLink();
  OverlayEntry? _paletteOverlay;
  final LayerLink _iconSetLink = LayerLink();
  OverlayEntry? _iconSetOverlay;

  int get _currentOriginalIndex => _visibleDesigns[widget.selectedDesign].originalIndex;

  void _togglePaletteOverlay() {
    if (_paletteOverlay != null) {
      _paletteOverlay!.remove();
      _paletteOverlay = null;
      return;
    }

    _paletteOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _paletteOverlay?.remove();
                _paletteOverlay = null;
              },
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _paletteLink,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(8, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 340,
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: PalettePicker(
                    currentDesignIndex: _currentOriginalIndex,
                    selectedPaletteIndex: widget.paletteIndex,
                    onPaletteSelected: (index) {
                      widget.onPaletteSelected(index);
                      _paletteOverlay?.remove();
                      _paletteOverlay = null;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_paletteOverlay!);
  }

  void _toggleIconSetOverlay() {
    if (_iconSetOverlay != null) {
      _iconSetOverlay!.remove();
      _iconSetOverlay = null;
      return;
    }

    _iconSetOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _iconSetOverlay?.remove();
                _iconSetOverlay = null;
              },
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _iconSetLink,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(8, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 340,
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: IconSetPicker(
                    currentDesignIndex: _currentOriginalIndex,
                    selectedIconSetIndex: widget.iconSetIndex,
                    onIconSetSelected: (index) {
                      widget.onIconSetSelected(index);
                      _iconSetOverlay?.remove();
                      _iconSetOverlay = null;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_iconSetOverlay!);
  }

  @override
  void dispose() {
    _paletteOverlay?.remove();
    _iconSetOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Design variant buttons
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'Design',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            for (int i = 0; i < _visibleDesigns.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _DesignButton(
                  design: _visibleDesigns[i],
                  index: i,
                  isSelected: i == widget.selectedDesign,
                  onTap: () => widget.onDesignSelected(i),
                ),
              ),

            // Palette picker trigger
            const SizedBox(height: 8),
            CompositedTransformTarget(
              link: _paletteLink,
              child: _TriggerButton(
                icon: Icons.palette_outlined,
                label: widget.paletteIndex != null
                    ? 'Palette: ${ColorPalette.visible[widget.paletteIndex!].shortName}'
                    : 'Color Palette',
                isActive: widget.paletteIndex != null,
                onTap: _togglePaletteOverlay,
              ),
            ),

            // Icon set picker trigger
            const SizedBox(height: 6),
            CompositedTransformTarget(
              link: _iconSetLink,
              child: _TriggerButton(
                icon: Icons.style_outlined,
                label: widget.iconSetIndex != null
                    ? 'Icons: ${ProtoIconSet.all[widget.iconSetIndex!].shortName}'
                    : 'Icon Set',
                isActive: widget.iconSetIndex != null,
                onTap: _toggleIconSetOverlay,
              ),
            ),

            // YoYo variant toggle
            const SizedBox(height: 12),
            _PillToggle(
              label: 'YoYo Version',
              option0: 'V1',
              option1: 'V2 Consent',
              selected: widget.yoyoVariant,
              onChanged: widget.onYoyoVariantChanged,
            ),

            // YoYo mode toggle
            const SizedBox(height: 6),
            _PillToggle(
              label: 'YoYo Mode',
              option0: 'Social',
              option1: 'Circle',
              selected: widget.yoyoMode,
              onChanged: widget.onYoyoModeChanged,
              activeColor1: const Color(0xFFD4A04A),
            ),

            // Route navigator
            const SizedBox(height: 16),
            RouteNavigator(onNavigate: widget.onNavigateRoute),
          ],
        ),
      ),
    );
  }
}

// ─── Design Button ──────────────────────────────────────────────────────

class _DesignButton extends StatelessWidget {
  final _DesignInfo design;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesignButton({
    required this.design,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? design.primaryColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? design.primaryColor
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: design.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                design.shortName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.35),
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

// ─── Trigger Button (for palette/icon set popovers) ────────────────────

class _TriggerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TriggerButton({
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.4),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pill Toggle ────────────────────────────────────────────────────────

class _PillToggle extends StatelessWidget {
  final String label;
  final String option0;
  final String option1;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? activeColor1;

  const _PillToggle({
    required this.label,
    required this.option0,
    required this.option1,
    required this.selected,
    required this.onChanged,
    this.activeColor1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _PillOption(
                text: option0,
                isSelected: selected == 0,
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _PillOption(
                text: option1,
                isSelected: selected == 1,
                onTap: () => onChanged(1),
                activeColor: activeColor1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PillOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _PillOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.12))
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (color != null ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.25))
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? (color ?? Colors.white.withValues(alpha: 0.9))
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
