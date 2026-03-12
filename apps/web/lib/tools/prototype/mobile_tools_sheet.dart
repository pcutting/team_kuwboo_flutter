import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/color_narratives.dart';
import '../../data/color_palettes.dart';
import '../../data/design_metadata.dart';
import '../../data/icon_narratives.dart';
import '../../data/icon_sets.dart';
import '../../prototype/proto_theme.dart';
import 'palette_picker.dart';
import 'icon_set_picker.dart';

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
  int _propertiesTab = 0; // 0 = Theme, 1 = Color, 2 = Icons

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
                // ── Controls Section ─────────────────────────────────
                _sectionLabel('Design Variant'),
                const SizedBox(height: 6),
                _buildDesignGrid(),

                const SizedBox(height: 16),
                _sectionLabel('Color Palette'),
                const SizedBox(height: 6),
                _buildPaletteSection(),

                const SizedBox(height: 16),
                _sectionLabel('Icon Set'),
                const SizedBox(height: 6),
                _buildIconSetSection(),

                const SizedBox(height: 16),
                _sectionLabel('YoYo Controls'),
                const SizedBox(height: 8),
                _buildYoyoToggles(),

                // ── Properties Panel ─────────────────────────────────
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 16),

                // Tab bar
                _PropertiesTabBar(
                  activeIndex: _propertiesTab,
                  accentColor: _designColors[widget.selectedDesign],
                  onChanged: (i) => setState(() => _propertiesTab = i),
                ),
                const SizedBox(height: 16),

                // Tab content
                if (_propertiesTab == 0)
                  _ThemeTabContent(
                    originalDesignIndex: _currentOriginalIndex,
                    accentColor: _designColors[widget.selectedDesign],
                  )
                else if (_propertiesTab == 1)
                  _ColorTabContent(
                    originalDesignIndex: _currentOriginalIndex,
                    paletteIndex: widget.paletteIndex,
                  )
                else
                  _IconsTabContent(
                    originalDesignIndex: _currentOriginalIndex,
                    iconSetIndex: widget.iconSetIndex,
                    accentColor: _designColors[widget.selectedDesign],
                  ),

                const SizedBox(height: 32),
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

// ─── Properties Tab Bar ─────────────────────────────────────────────────

class _PropertiesTabBar extends StatelessWidget {
  final int activeIndex;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  const _PropertiesTabBar({
    required this.activeIndex,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabPill(label: 'Theme', isActive: activeIndex == 0, accentColor: accentColor, onTap: () => onChanged(0)),
        const SizedBox(width: 8),
        _TabPill(label: 'Color', isActive: activeIndex == 1, accentColor: accentColor, onTap: () => onChanged(1)),
        const SizedBox(width: 8),
        _TabPill(label: 'Icons', isActive: activeIndex == 2, accentColor: accentColor, onTap: () => onChanged(2)),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? accentColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

// ─── Tab 0: Theme ───────────────────────────────────────────────────────

class _ThemeTabContent extends StatelessWidget {
  final int originalDesignIndex;
  final Color accentColor;

  const _ThemeTabContent({
    required this.originalDesignIndex,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final meta = DesignMetadataEntry.forDesign(originalDesignIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STYLE
        _SectionTitle('STYLE'),
        const SizedBox(height: 8),
        Text(
          meta.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            meta.target,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: accentColor),
          ),
        ),

        // PHILOSOPHY
        const SizedBox(height: 24),
        _SectionTitle('PHILOSOPHY'),
        const SizedBox(height: 8),
        Text(
          meta.philosophy,
          style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // TYPOGRAPHY
        const SizedBox(height: 24),
        _SectionTitle('TYPOGRAPHY'),
        const SizedBox(height: 8),
        _TypographySample(name: meta.headlineFont, role: 'Headlines'),
        const SizedBox(height: 8),
        _TypographySample(name: meta.bodyFont, role: 'Body'),

        // KEY ELEMENTS
        const SizedBox(height: 24),
        _SectionTitle('KEY ELEMENTS'),
        const SizedBox(height: 8),
        ...meta.keyElements.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            )),

        // SCORES
        const SizedBox(height: 24),
        _SectionTitle('SCORES'),
        const SizedBox(height: 8),
        _ScoreRow(label: 'Distinctiveness', score: meta.scores.distinctiveness, color: accentColor),
        _ScoreRow(label: 'Coherence', score: meta.scores.coherence, color: accentColor),
        _ScoreRow(label: 'Usability', score: meta.scores.usability, color: accentColor),
        _ScoreRow(label: 'Target Fit', score: meta.scores.targetFit, color: accentColor),
        _ScoreRow(label: 'Longevity', score: meta.scores.longevity, color: accentColor),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OVERALL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Colors.white54),
              ),
              Text(
                '${meta.scores.overall.toStringAsFixed(1)}/5',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: accentColor),
              ),
            ],
          ),
        ),

        // CRITIQUE
        const SizedBox(height: 24),
        _SectionTitle('CRITIQUE'),
        const SizedBox(height: 8),
        _CritiqueItem(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF22c55e),
          label: 'What works',
          text: meta.works,
        ),
        const SizedBox(height: 12),
        _CritiqueItem(
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFf59e0b),
          label: 'Weakness',
          text: meta.weakness,
        ),
      ],
    );
  }
}

// ─── Tab 1: Color ───────────────────────────────────────────────────────

class _ColorTabContent extends StatelessWidget {
  final int originalDesignIndex;
  final int? paletteIndex;

  const _ColorTabContent({
    required this.originalDesignIndex,
    this.paletteIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.fromDesignIndex(originalDesignIndex);
    final activeTheme = paletteIndex != null
        ? theme.withPalette(ColorPalette.visible[paletteIndex!])
        : theme;

    final narrative = paletteIndex != null
        ? ColorNarrative.forPalette(paletteIndex!)
        : ColorNarrative.forDesign(originalDesignIndex);

    final sourceLabel = paletteIndex != null
        ? ColorPalette.visible[paletteIndex!].name
        : _designNames[_designIndexMap.indexOf(originalDesignIndex)];

    final accentColor = activeTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ACTIVE PALETTE
        _SectionTitle('ACTIVE PALETTE'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            sourceLabel,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
          ),
        ),
        const SizedBox(height: 14),
        _SwatchGrid(theme: activeTheme),

        // EMOTIONAL TONE
        const SizedBox(height: 24),
        _SectionTitle('EMOTIONAL TONE'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            narrative.emotionalTone,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: narrative.emotions
              .map((e) => _EmotionChip(e))
              .toList(),
        ),

        // PSYCHOLOGY
        const SizedBox(height: 24),
        _SectionTitle('PSYCHOLOGY'),
        const SizedBox(height: 8),
        Text(
          narrative.psychology,
          style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // HARMONY
        const SizedBox(height: 24),
        _SectionTitle('HARMONY'),
        const SizedBox(height: 8),
        Text(
          narrative.harmonyType,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 8),
        _HarmonyCircles(theme: activeTheme),
        const SizedBox(height: 10),
        Text(
          narrative.harmonyExplain,
          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.6)),
        ),

        // BEST FOR
        const SizedBox(height: 24),
        _SectionTitle('BEST FOR'),
        const SizedBox(height: 8),
        Text(
          narrative.bestFor,
          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // CONTRAST
        const SizedBox(height: 24),
        _SectionTitle('CONTRAST'),
        const SizedBox(height: 8),
        _ContrastBadge(
          label: 'Text on Background',
          foreground: activeTheme.text,
          background: activeTheme.background,
        ),
        const SizedBox(height: 6),
        _ContrastBadge(
          label: 'Primary on Surface',
          foreground: activeTheme.primary,
          background: activeTheme.surface,
        ),
        const SizedBox(height: 10),
        Text(
          narrative.contrastNote,
          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.6)),
        ),

        // COLOR CRITIQUE
        const SizedBox(height: 24),
        _SectionTitle('COLOR CRITIQUE'),
        const SizedBox(height: 8),
        _CritiqueItem(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF22c55e),
          label: 'What works',
          text: narrative.colorWorks,
        ),
        const SizedBox(height: 12),
        _CritiqueItem(
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFf59e0b),
          label: 'Weakness',
          text: narrative.colorWeakness,
        ),
      ],
    );
  }
}

// ─── Tab 2: Icons ───────────────────────────────────────────────────────

class _IconsTabContent extends StatelessWidget {
  final int originalDesignIndex;
  final int? iconSetIndex;
  final Color accentColor;

  const _IconsTabContent({
    required this.originalDesignIndex,
    this.iconSetIndex,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeSet = iconSetIndex != null
        ? ProtoIconSet.all[iconSetIndex!]
        : ProtoIconSet.modernOutlined;

    final narrative = iconSetIndex != null
        ? IconSetNarrative.forIconSet(iconSetIndex!)
        : IconSetNarrative.forIconSet(0);

    final sourceLabel = iconSetIndex != null
        ? activeSet.name
        : 'Default';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ACTIVE SET
        _SectionTitle('ACTIVE SET'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            sourceLabel,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
          ),
        ),

        // ICON SHOWCASE
        const SizedBox(height: 16),
        _SectionTitle('ICON SHOWCASE'),
        const SizedBox(height: 8),
        _IconShowcase(iconSet: activeSet),

        // EMOTIONAL TONE
        const SizedBox(height: 24),
        _SectionTitle('EMOTIONAL TONE'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            narrative.emotionalTone,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: narrative.emotions.map((e) => _EmotionChip(e)).toList(),
        ),

        // PSYCHOLOGY
        const SizedBox(height: 24),
        _SectionTitle('PSYCHOLOGY'),
        const SizedBox(height: 8),
        Text(
          narrative.psychology,
          style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // DESIGN PHILOSOPHY
        const SizedBox(height: 24),
        _SectionTitle('DESIGN PHILOSOPHY'),
        const SizedBox(height: 8),
        Text(
          narrative.designPhilosophy,
          style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // RECOGNIZABILITY
        const SizedBox(height: 24),
        _SectionTitle('RECOGNIZABILITY'),
        const SizedBox(height: 8),
        Text(
          narrative.recognizability,
          style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // BEST FOR
        const SizedBox(height: 24),
        _SectionTitle('BEST FOR'),
        const SizedBox(height: 8),
        Text(
          narrative.bestFor,
          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.7)),
        ),

        // ICON CRITIQUE
        const SizedBox(height: 24),
        _SectionTitle('ICON CRITIQUE'),
        const SizedBox(height: 8),
        _CritiqueItem(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF22c55e),
          label: 'What works',
          text: narrative.iconWorks,
        ),
        const SizedBox(height: 12),
        _CritiqueItem(
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFf59e0b),
          label: 'Weakness',
          text: narrative.iconWeakness,
        ),
      ],
    );
  }
}

// ─── Icon Showcase Grid ─────────────────────────────────────────────────

class _IconShowcase extends StatelessWidget {
  final ProtoIconSet iconSet;

  const _IconShowcase({required this.iconSet});

  @override
  Widget build(BuildContext context) {
    final icons = [
      ('Search', iconSet.search),
      ('Share', iconSet.share),
      ('Settings', iconSet.settings),
      ('Close', iconSet.close),
      ('Check', iconSet.check),
      ('Send', iconSet.send),
      ('Edit', iconSet.edit),
      ('Notify', iconSet.notifications),
      ('Chat', iconSet.chatBubbleOutline),
      ('More', iconSet.moreHoriz),
      ('Fav', iconSet.favoriteFilled),
      ('Save', iconSet.bookmarkFilled),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: icons.map((entry) {
        return SizedBox(
          width: 48,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Center(
                  child: Icon(entry.$2, size: 20, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                entry.$1,
                style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── 3x3 Swatch Grid ───────────────────────────────────────────────────

class _SwatchGrid extends StatelessWidget {
  final ProtoTheme theme;

  const _SwatchGrid({required this.theme});

  @override
  Widget build(BuildContext context) {
    final swatches = [
      ('Primary', theme.primary),
      ('Secondary', theme.secondary),
      ('Accent', theme.accent),
      ('Tertiary', theme.tertiary),
      ('Background', theme.background),
      ('Surface', theme.surface),
      ('Text', theme.text),
      ('Text 2nd', theme.textSecondary),
      ('Text 3rd', theme.textTertiary),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: swatches
          .map((s) => _ColorSwatch(label: s.$1, color: s.$2))
          .toList(),
    );
  }
}

// ─── Harmony Circles ────────────────────────────────────────────────────

class _HarmonyCircles extends StatelessWidget {
  final ProtoTheme theme;

  const _HarmonyCircles({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = [theme.primary, theme.secondary, theme.accent, theme.tertiary];
    return SizedBox(
      height: 32,
      child: Row(
        children: List.generate(colors.length, (i) {
          return Align(
            widthFactor: 0.7,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A1A24), width: 2),
                boxShadow: [
                  BoxShadow(color: colors[i].withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Contrast Badge ─────────────────────────────────────────────────────

class _ContrastBadge extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _ContrastBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  double _contrastRatio(Color fg, Color bg) {
    final l1 = max(fg.computeLuminance(), bg.computeLuminance());
    final l2 = min(fg.computeLuminance(), bg.computeLuminance());
    return (l1 + 0.05) / (l2 + 0.05);
  }

  String _wcagLevel(double ratio) {
    if (ratio >= 7.0) return 'AAA';
    if (ratio >= 4.5) return 'AA';
    if (ratio >= 3.0) return 'AA Large';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _contrastRatio(foreground, background);
    final level = _wcagLevel(ratio);
    final passed = ratio >= 4.5;

    return Row(
      children: [
        Container(
          width: 28,
          height: 20,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Center(
            child: Text(
              'Aa',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: foreground),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: passed
                ? const Color(0xFF22c55e).withValues(alpha: 0.15)
                : const Color(0xFFf59e0b).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${ratio.toStringAsFixed(1)}:1 $level',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: passed ? const Color(0xFF22c55e) : const Color(0xFFf59e0b),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}

class _ColorSwatch extends StatefulWidget {
  final String label;
  final Color color;

  const _ColorSwatch({required this.label, required this.color});

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch> {
  bool _copied = false;

  String _colorToHex(Color color) {
    final r = color.r.toInt().clamp(0, 255);
    final g = color.g.toInt().clamp(0, 255);
    final b = color.b.toInt().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  void _copyColor() {
    final hex = _colorToHex(widget.color);
    Clipboard.setData(ClipboardData(text: hex));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copyColor,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _copied
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  final String text;
  const _EmotionChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _TypographySample extends StatelessWidget {
  final String name;
  final String role;

  const _TypographySample({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            role,
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreRow({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (i) {
                final filled = i < score;
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: filled ? color : Colors.white.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CritiqueItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String text;

  const _CritiqueItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
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
