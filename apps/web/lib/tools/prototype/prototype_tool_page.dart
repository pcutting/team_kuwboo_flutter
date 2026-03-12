import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/color_palettes.dart';
import '../../data/icon_sets.dart';
import '../../prototype/prototype_app.dart';
import 'mobile_tools_sheet.dart';
import 'phone_frame.dart';
import 'prototype_sidebar.dart';

/// Maps visible sidebar index (0-3) to PrototypeApp designIndex (0-7).
const _designIndexMap = [0, 3, 4, 6];

class PrototypeToolPage extends StatefulWidget {
  const PrototypeToolPage({super.key});

  @override
  State<PrototypeToolPage> createState() => _PrototypeToolPageState();
}

class _PrototypeToolPageState extends State<PrototypeToolPage> {
  int _selectedDesign = 0;
  int? _selectedPalette;
  int? _selectedIconSet;
  int _yoyoVariant = 0;
  int _yoyoMode = 0;
  bool _sidebarVisible = true;
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<String?> _navigateNotifier = ValueNotifier(null);

  int get _originalDesignIndex => _designIndexMap[_selectedDesign];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _navigateNotifier.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    // 1-4 for design switching
    if (key == LogicalKeyboardKey.digit1) {
      setState(() => _selectedDesign = 0);
      return;
    } else if (key == LogicalKeyboardKey.digit2) {
      setState(() => _selectedDesign = 1);
      return;
    } else if (key == LogicalKeyboardKey.digit3) {
      setState(() => _selectedDesign = 2);
      return;
    } else if (key == LogicalKeyboardKey.digit4) {
      setState(() => _selectedDesign = 3);
      return;
    }

    // P cycles palettes: null -> 0 -> 1 -> ... -> (length-1) -> null
    if (key == LogicalKeyboardKey.keyP) {
      setState(() {
        if (_selectedPalette == null) {
          _selectedPalette = 0;
        } else if (_selectedPalette! >= ColorPalette.visible.length - 1) {
          _selectedPalette = null;
        } else {
          _selectedPalette = _selectedPalette! + 1;
        }
      });
      return;
    }

    // I cycles icon sets: null -> 0 -> 1 -> 2 -> 3 -> null
    if (key == LogicalKeyboardKey.keyI) {
      setState(() {
        if (_selectedIconSet == null) {
          _selectedIconSet = 0;
        } else if (_selectedIconSet! >= ProtoIconSet.all.length - 1) {
          _selectedIconSet = null;
        } else {
          _selectedIconSet = _selectedIconSet! + 1;
        }
      });
      return;
    }
  }

  void _showMobileToolsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (context, scrollController) => MobileToolsSheet(
          selectedDesign: _selectedDesign,
          onDesignSelected: (i) => setState(() => _selectedDesign = i),
          paletteIndex: _selectedPalette,
          onPaletteSelected: (i) => setState(() => _selectedPalette = i),
          iconSetIndex: _selectedIconSet,
          onIconSetSelected: (i) => setState(() => _selectedIconSet = i),
          yoyoVariant: _yoyoVariant,
          onYoyoVariantChanged: (v) => setState(() => _yoyoVariant = v),
          yoyoMode: _yoyoMode,
          onYoyoModeChanged: (m) => setState(() => _yoyoMode = m),
          onNavigateRoute: (route) => _navigateNotifier.value = route,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 800;

    if (isMobile) {
      return _buildMobileLayout();
    }

    final showSidebar = _sidebarVisible;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Row(
        children: [
          // Sidebar
          if (showSidebar)
            PrototypeSidebar(
              selectedDesign: _selectedDesign,
              onDesignSelected: (i) => setState(() => _selectedDesign = i),
              paletteIndex: _selectedPalette,
              onPaletteSelected: (i) => setState(() => _selectedPalette = i),
              iconSetIndex: _selectedIconSet,
              onIconSetSelected: (i) => setState(() => _selectedIconSet = i),
              yoyoVariant: _yoyoVariant,
              onYoyoVariantChanged: (v) => setState(() => _yoyoVariant = v),
              yoyoMode: _yoyoMode,
              onYoyoModeChanged: (m) => setState(() => _yoyoMode = m),
              onNavigateRoute: (route) => _navigateNotifier.value = route,
            ),
          // Main area
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Design label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _DesignLabel(
                          designIndex: _selectedDesign,
                          paletteIndex: _selectedPalette,
                          iconSetIndex: _selectedIconSet,
                        ),
                      ),
                      // Phone frame
                      PhoneFrame(
                        child: PrototypeApp(
                          designIndex: _originalDesignIndex,
                          paletteIndex: _selectedPalette,
                          iconSetIndex: _selectedIconSet,
                          yoyoVariant: _yoyoVariant,
                          onYoyoVariantChanged: (v) => setState(() => _yoyoVariant = v),
                          yoyoMode: _yoyoMode,
                          onYoyoModeChanged: (m) => setState(() => _yoyoMode = m),
                          navigateNotifier: _navigateNotifier,
                        ),
                      ),
                      // Hint
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'Interactive prototype \u2022 Tap to navigate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sidebar toggle
                if (!_sidebarVisible)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _sidebarVisible = true),
                      tooltip: 'Show sidebar',
                    ),
                  ),
                if (_sidebarVisible)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_open_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _sidebarVisible = false),
                      tooltip: 'Hide sidebar',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    // Active design primary color for the trigger dot
    final activePrimary = _selectedPalette != null
        ? ColorPalette.visible[_selectedPalette!].primary
        : _designColors[_selectedDesign];

    return Stack(
      children: [
        // Prototype edge-to-edge (no PhoneFrame, no DesignLabel, no hint)
        Positioned.fill(
          child: PrototypeApp(
            designIndex: _originalDesignIndex,
            paletteIndex: _selectedPalette,
            iconSetIndex: _selectedIconSet,
            yoyoVariant: _yoyoVariant,
            onYoyoVariantChanged: (v) => setState(() => _yoyoVariant = v),
            yoyoMode: _yoyoMode,
            onYoyoModeChanged: (m) => setState(() => _yoyoMode = m),
            navigateNotifier: _navigateNotifier,
          ),
        ),
        // Floating trigger button (top-left)
        Positioned(
          left: 12,
          top: 12,
          child: GestureDetector(
            onTap: _showMobileToolsSheet,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24).withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  // Active color dot
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: activePrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1A1A24),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Design Label ───────────────────────────────────────────────────────

const _designNames = ['Urban Warmth', 'Dark Mode', 'Organic Warmth', 'Street'];
const _designColors = [Color(0xFFCB6843), Color(0xFF8B5CF6), Color(0xFFCB6843), Color(0xFFE63946)];

class _DesignLabel extends StatelessWidget {
  final int designIndex;
  final int? paletteIndex;
  final int? iconSetIndex;

  const _DesignLabel({
    required this.designIndex,
    this.paletteIndex,
    this.iconSetIndex,
  });

  @override
  Widget build(BuildContext context) {
    final paletteSuffix = paletteIndex != null
        ? ' \u2022 ${ColorPalette.visible[paletteIndex!].shortName}'
        : '';
    final iconSuffix = iconSetIndex != null
        ? ' \u2022 ${ProtoIconSet.all[iconSetIndex!].shortName}'
        : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: paletteIndex != null
                ? ColorPalette.visible[paletteIndex!].primary
                : _designColors[designIndex],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${_designNames[designIndex]}$paletteSuffix$iconSuffix',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
