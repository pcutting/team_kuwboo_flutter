import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/color_narratives.dart';
import '../data/color_palettes.dart';
import '../data/design_registry.dart';
import '../data/icon_narratives.dart';
import '../data/icon_sets.dart';
import '../prototype/proto_theme.dart';

class PropertiesPanel extends StatefulWidget {
  final DesignMetadata design;
  final int designIndex;
  final int? paletteIndex;
  final int? iconSetIndex;
  final ScrollController? scrollController;
  final bool compact;

  const PropertiesPanel({
    super.key,
    required this.design,
    required this.designIndex,
    this.paletteIndex,
    this.iconSetIndex,
    this.scrollController,
    this.compact = false,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  int _activeTab = 0; // 0 = Theme, 1 = Color, 2 = Icons

  @override
  Widget build(BuildContext context) {
    final pad = widget.compact ? 20.0 : 32.0;

    return Container(
      color: const Color(0xFF16161e),
      child: Column(
        children: [
          // ── Tab bar ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(pad, widget.compact ? 4 : pad / 2, pad, 0),
            child: _TabBar(
              activeIndex: _activeTab,
              accentColor: widget.design.palette.primary,
              onChanged: (i) => setState(() => _activeTab = i),
            ),
          ),
          const SizedBox(height: 4),
          // ── Tab content ─────────────────────────────────────────
          Expanded(
            child: _activeTab == 0
                ? _ThemeTab(
                    design: widget.design,
                    scrollController: widget.scrollController,
                    compact: widget.compact,
                  )
                : _activeTab == 1
                    ? _ColorTab(
                        design: widget.design,
                        designIndex: widget.designIndex,
                        paletteIndex: widget.paletteIndex,
                        scrollController: widget.scrollController,
                        compact: widget.compact,
                      )
                    : _IconsTab(
                        design: widget.design,
                        designIndex: widget.designIndex,
                        iconSetIndex: widget.iconSetIndex,
                        scrollController: widget.scrollController,
                        compact: widget.compact,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int activeIndex;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  const _TabBar({
    required this.activeIndex,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabPill(
          label: 'Theme',
          isActive: activeIndex == 0,
          accentColor: accentColor,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Color',
          isActive: activeIndex == 1,
          accentColor: accentColor,
          onTap: () => onChanged(1),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Icons',
          isActive: activeIndex == 2,
          accentColor: accentColor,
          onTap: () => onChanged(2),
        ),
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
          color: isActive
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? accentColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
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

// ─── Tab 0: Theme ────────────────────────────────────────────────────────

class _ThemeTab extends StatelessWidget {
  final DesignMetadata design;
  final ScrollController? scrollController;
  final bool compact;

  const _ThemeTab({
    required this.design,
    this.scrollController,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(compact ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STYLE
          _Section(
            title: 'STYLE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: design.palette.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: design.palette.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    design.target,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: design.palette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // PHILOSOPHY
          _Section(
            title: 'PHILOSOPHY',
            child: Text(
              design.philosophy,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // TYPOGRAPHY
          _Section(
            title: 'TYPOGRAPHY',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypographySample(
                  name: design.typography.headline,
                  role: 'Headlines',
                ),
                const SizedBox(height: 12),
                _TypographySample(
                  name: design.typography.body,
                  role: 'Body',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // KEY ELEMENTS
          _Section(
            title: 'KEY ELEMENTS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: design.keyElements
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: design.palette.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          // SCORES
          _Section(
            title: 'SCORES',
            child: Column(
              children: [
                _ScoreRow(
                  label: 'Distinctiveness',
                  score: design.scores.distinctiveness,
                  color: design.palette.primary,
                ),
                _ScoreRow(
                  label: 'Coherence',
                  score: design.scores.coherence,
                  color: design.palette.primary,
                ),
                _ScoreRow(
                  label: 'Usability',
                  score: design.scores.usability,
                  color: design.palette.primary,
                ),
                _ScoreRow(
                  label: 'Target Fit',
                  score: design.scores.targetFit,
                  color: design.palette.primary,
                ),
                _ScoreRow(
                  label: 'Longevity',
                  score: design.scores.longevity,
                  color: design.palette.primary,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: design.palette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: design.palette.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'OVERALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '${design.scores.overall.toStringAsFixed(1)}/5',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: design.palette.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // CRITIQUE
          _Section(
            title: 'CRITIQUE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CritiqueItem(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF22c55e),
                  label: 'What works',
                  text: design.critique.works,
                ),
                const SizedBox(height: 16),
                _CritiqueItem(
                  icon: Icons.warning_rounded,
                  iconColor: const Color(0xFFf59e0b),
                  label: 'Weakness',
                  text: design.critique.weakness,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1: Color ────────────────────────────────────────────────────────

class _ColorTab extends StatelessWidget {
  final DesignMetadata design;
  final int designIndex;
  final int? paletteIndex;
  final ScrollController? scrollController;
  final bool compact;

  const _ColorTab({
    required this.design,
    required this.designIndex,
    this.paletteIndex,
    this.scrollController,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve the active 9-color theme
    final theme = ProtoTheme.fromDesignIndex(designIndex);
    final activeTheme = paletteIndex != null
        ? theme.withPalette(ColorPalette.visible[paletteIndex!])
        : theme;

    // Resolve narrative
    final narrative = paletteIndex != null
        ? ColorNarrative.forPalette(paletteIndex!)
        : ColorNarrative.forDesign(designIndex);

    // Source label
    final designs = DesignRegistry.getDesigns(DesignSet.setC);
    final designName = designs[designIndex].shortName;
    final sourceLabel = paletteIndex != null
        ? ColorPalette.visible[paletteIndex!].name
        : 'V${designIndex + 1} $designName Default';

    final pad = compact ? 20.0 : 32.0;
    final accentColor = activeTheme.primary;

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ACTIVE PALETTE
          _Section(
            title: 'ACTIVE PALETTE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    sourceLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 3x3 swatch grid
                _SwatchGrid(theme: activeTheme),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // EMOTIONAL TONE
          _Section(
            title: 'EMOTIONAL TONE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    narrative.emotionalTone,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: narrative.emotions
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // PSYCHOLOGY
          _Section(
            title: 'PSYCHOLOGY',
            child: Text(
              narrative.psychology,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // HARMONY
          _Section(
            title: 'HARMONY',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  narrative.harmonyType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Harmony circles
                _HarmonyCircles(theme: activeTheme),
                const SizedBox(height: 12),
                Text(
                  narrative.harmonyExplain,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // BEST FOR
          _Section(
            title: 'BEST FOR',
            child: Text(
              narrative.bestFor,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // CONTRAST
          _Section(
            title: 'CONTRAST',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContrastBadge(
                  label: 'Text on Background',
                  foreground: activeTheme.text,
                  background: activeTheme.background,
                ),
                const SizedBox(height: 8),
                _ContrastBadge(
                  label: 'Primary on Surface',
                  foreground: activeTheme.primary,
                  background: activeTheme.surface,
                ),
                const SizedBox(height: 12),
                Text(
                  narrative.contrastNote,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // COLOR CRITIQUE
          _Section(
            title: 'COLOR CRITIQUE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CritiqueItem(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF22c55e),
                  label: 'What works',
                  text: narrative.colorWorks,
                ),
                const SizedBox(height: 16),
                _CritiqueItem(
                  icon: Icons.warning_rounded,
                  iconColor: const Color(0xFFf59e0b),
                  label: 'Weakness',
                  text: narrative.colorWeakness,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: Icons ───────────────────────────────────────────────────────

class _IconsTab extends StatefulWidget {
  final DesignMetadata design;
  final int designIndex;
  final int? iconSetIndex;
  final ScrollController? scrollController;
  final bool compact;

  const _IconsTab({
    required this.design,
    required this.designIndex,
    this.iconSetIndex,
    this.scrollController,
    this.compact = false,
  });

  @override
  State<_IconsTab> createState() => _IconsTabState();
}

class _IconsTabState extends State<_IconsTab> {
  int? _compareIndex;
  String? _magnifiedIcon;

  int get _activeIndex => widget.iconSetIndex ?? 0;

  @override
  void didUpdateWidget(covariant _IconsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset comparison if the active set changed to match the compare set
    if (_compareIndex != null && _compareIndex == _activeIndex) {
      _compareIndex = null;
      _magnifiedIcon = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSet = widget.iconSetIndex != null
        ? ProtoIconSet.all[widget.iconSetIndex!]
        : ProtoIconSet.modernOutlined;

    final narrative = widget.iconSetIndex != null
        ? IconSetNarrative.forIconSet(widget.iconSetIndex!)
        : IconSetNarrative.forIconSet(0);

    final sourceLabel = widget.iconSetIndex != null
        ? activeSet.name
        : 'V${widget.designIndex + 1} Default';

    final pad = widget.compact ? 20.0 : 32.0;
    final accentColor = widget.design.palette.primary;

    final comparing = _compareIndex != null;
    final compareSet = comparing ? ProtoIconSet.all[_compareIndex!] : null;
    final compareNarrative =
        comparing ? IconSetNarrative.forIconSet(_compareIndex!) : null;
    const compareColor = Color(0xFF8b95a5);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ACTIVE SET
          _Section(
            title: 'ACTIVE SET',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    sourceLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // COMPARE WITH
          _Section(
            title: 'COMPARE WITH',
            child: _CompareChips(
              activeIndex: _activeIndex,
              compareIndex: _compareIndex,
              accentColor: accentColor,
              onChanged: (i) => setState(() {
                _compareIndex = i;
                _magnifiedIcon = null;
              }),
            ),
          ),
          const SizedBox(height: 32),
          // ICON SHOWCASE
          _Section(
            title: 'ICON SHOWCASE',
            child: comparing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Diff summary
                      _DiffSummary(
                        activeSet: activeSet,
                        compareSet: compareSet!,
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      // Column labels
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activeSet.shortName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              compareSet.shortName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: compareColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Side-by-side grids with tap handlers
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _IconShowcase(
                              iconSet: activeSet,
                              compact: true,
                              compareSet: compareSet,
                              selectedName: _magnifiedIcon,
                              onIconTap: (name) => setState(() {
                                _magnifiedIcon =
                                    _magnifiedIcon == name ? null : name;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _IconShowcase(
                              iconSet: compareSet,
                              compact: true,
                              compareSet: activeSet,
                              selectedName: _magnifiedIcon,
                              onIconTap: (name) => setState(() {
                                _magnifiedIcon =
                                    _magnifiedIcon == name ? null : name;
                              }),
                            ),
                          ),
                        ],
                      ),
                      // Magnified comparison card
                      if (_magnifiedIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Builder(builder: (context) {
                            final iconNames = _showcaseIconList(activeSet)
                                .where((e) => !const {
                                      'Add',
                                      'Camera',
                                      'Star',
                                      'Tune'
                                    }.contains(e.$1))
                                .map((e) => e.$1)
                                .toList();
                            final idx = iconNames.indexOf(_magnifiedIcon!);
                            return _MagnifiedComparison(
                              iconName: _magnifiedIcon!,
                              activeSet: activeSet,
                              compareSet: compareSet,
                              accentColor: accentColor,
                              currentIndex: idx,
                              totalCount: iconNames.length,
                              onDismiss: () =>
                                  setState(() => _magnifiedIcon = null),
                              onPrev: idx > 0
                                  ? () => setState(() =>
                                      _magnifiedIcon = iconNames[idx - 1])
                                  : null,
                              onNext: idx < iconNames.length - 1
                                  ? () => setState(() =>
                                      _magnifiedIcon = iconNames[idx + 1])
                                  : null,
                            );
                          }),
                        ),
                    ],
                  )
                : _IconShowcase(iconSet: activeSet),
          ),
          const SizedBox(height: 32),
          // EMOTIONAL TONE
          _Section(
            title: 'EMOTIONAL TONE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NarrativeLabel(
                  label: comparing ? activeSet.shortName : null,
                  color: accentColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      narrative.emotionalTone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: narrative.emotions
                      .map((e) => _EmotionChip(e))
                      .toList(),
                ),
                if (comparing) ...[
                  const SizedBox(height: 16),
                  _NarrativeLabel(
                    label: compareSet!.shortName,
                    color: compareColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: compareColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        compareNarrative!.emotionalTone,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: compareColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: compareNarrative.emotions
                        .map((e) => _EmotionChip(e))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          // PSYCHOLOGY
          _NarrativeComparison(
            title: 'PSYCHOLOGY',
            activeText: narrative.psychology,
            activeLabel: comparing ? activeSet.shortName : null,
            accentColor: accentColor,
            compareText: compareNarrative?.psychology,
            compareLabel: compareSet?.shortName,
          ),
          const SizedBox(height: 32),
          // DESIGN PHILOSOPHY
          _NarrativeComparison(
            title: 'DESIGN PHILOSOPHY',
            activeText: narrative.designPhilosophy,
            activeLabel: comparing ? activeSet.shortName : null,
            accentColor: accentColor,
            compareText: compareNarrative?.designPhilosophy,
            compareLabel: compareSet?.shortName,
          ),
          const SizedBox(height: 32),
          // RECOGNIZABILITY
          _NarrativeComparison(
            title: 'RECOGNIZABILITY',
            activeText: narrative.recognizability,
            activeLabel: comparing ? activeSet.shortName : null,
            accentColor: accentColor,
            compareText: compareNarrative?.recognizability,
            compareLabel: compareSet?.shortName,
          ),
          const SizedBox(height: 32),
          // BEST FOR
          _NarrativeComparison(
            title: 'BEST FOR',
            activeText: narrative.bestFor,
            activeLabel: comparing ? activeSet.shortName : null,
            accentColor: accentColor,
            compareText: compareNarrative?.bestFor,
            compareLabel: compareSet?.shortName,
          ),
          const SizedBox(height: 32),
          // ICON CRITIQUE
          _Section(
            title: 'ICON CRITIQUE',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comparing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DotLabel(
                      label: activeSet.shortName,
                      color: accentColor,
                    ),
                  ),
                _CritiqueItem(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF22c55e),
                  label: 'What works',
                  text: narrative.iconWorks,
                ),
                const SizedBox(height: 16),
                _CritiqueItem(
                  icon: Icons.warning_rounded,
                  iconColor: const Color(0xFFf59e0b),
                  label: 'Weakness',
                  text: narrative.iconWeakness,
                ),
                if (comparing) ...[
                  const SizedBox(height: 24),
                  _DotLabel(
                    label: compareSet!.shortName,
                    color: compareColor,
                  ),
                  const SizedBox(height: 8),
                  _CritiqueItem(
                    icon: Icons.check_circle_rounded,
                    iconColor: const Color(0xFF22c55e),
                    label: 'What works',
                    text: compareNarrative!.iconWorks,
                  ),
                  const SizedBox(height: 16),
                  _CritiqueItem(
                    icon: Icons.warning_rounded,
                    iconColor: const Color(0xFFf59e0b),
                    label: 'Weakness',
                    text: compareNarrative.iconWeakness,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Icon Showcase Grid ─────────────────────────────────────────────────

class _IconShowcase extends StatelessWidget {
  final ProtoIconSet iconSet;
  final bool compact;
  final ProtoIconSet? compareSet;
  final String? selectedName;
  final ValueChanged<String>? onIconTap;

  const _IconShowcase({
    required this.iconSet,
    this.compact = false,
    this.compareSet,
    this.selectedName,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final allIcons = _showcaseIconList(iconSet);
    final compareIcons =
        compareSet != null ? _showcaseIconList(compareSet!) : null;

    // In compact mode, drop 4 icons so 12 fit in 3-per-row side-by-side
    final icons = compact
        ? allIcons
            .where(
                (e) => !const {'Add', 'Camera', 'Star', 'Tune'}.contains(e.$1))
            .toList()
        : allIcons;

    final boxSize = compact ? 34.0 : 40.0;
    final iconSize = compact ? 18.0 : 22.0;
    final cellWidth = compact ? 46.0 : 56.0;
    final spacing = compact ? 8.0 : 12.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: icons.map((entry) {
        final name = entry.$1;
        final isSelected = selectedName == name;
        final isTappable = onIconTap != null;

        // Check if this icon differs from the compare set
        final isSame = compareIcons != null &&
            compareIcons
                .any((c) => c.$1 == name && c.$2.codePoint == entry.$2.codePoint);

        return GestureDetector(
          onTap: isTappable ? () => onIconTap!(name) : null,
          child: SizedBox(
            width: cellWidth,
            child: Column(
              children: [
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(compact ? 6 : 8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.4)
                          : compareSet != null && !isSame
                              ? const Color(0xFF22c55e).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      entry.$2,
                      size: iconSize,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: compact ? 8 : 9,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : compareSet != null && isSame
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Returns the 16 showcase icons for a given icon set.
List<(String, IconData)> _showcaseIconList(ProtoIconSet set) => [
      ('Search', set.search),
      ('Share', set.share),
      ('Settings', set.settings),
      ('Close', set.close),
      ('Check', set.check),
      ('Send', set.send),
      ('Edit', set.edit),
      ('Add', set.add),
      ('Notifications', set.notifications),
      ('Camera', set.cameraAlt),
      ('Chat', set.chatBubbleOutline),
      ('More', set.moreHoriz),
      ('Favorite', set.favoriteFilled),
      ('Bookmark', set.bookmarkFilled),
      ('Star', set.starFilled),
      ('Tune', set.tune),
    ];

// ─── Magnified Comparison ───────────────────────────────────────────────

class _MagnifiedComparison extends StatelessWidget {
  final String iconName;
  final ProtoIconSet activeSet;
  final ProtoIconSet compareSet;
  final Color accentColor;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onDismiss;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _MagnifiedComparison({
    required this.iconName,
    required this.activeSet,
    required this.compareSet,
    required this.accentColor,
    required this.currentIndex,
    required this.totalCount,
    required this.onDismiss,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final activeIcons = _showcaseIconList(activeSet);
    final compareIcons = _showcaseIconList(compareSet);

    final activeIcon = activeIcons
        .firstWhere((e) => e.$1 == iconName,
            orElse: () => (iconName, Icons.help_outline))
        .$2;
    final compareIcon = compareIcons
        .firstWhere((e) => e.$1 == iconName,
            orElse: () => (iconName, Icons.help_outline))
        .$2;

    final isSame = activeIcon.codePoint == compareIcon.codePoint;
    const compareColor = Color(0xFF8b95a5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSame
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF22c55e).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header: name + badge + close
          Row(
            children: [
              Expanded(
                child: Text(
                  iconName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSame
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFF22c55e).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isSame ? 'IDENTICAL' : 'DIFFERENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isSame
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFF22c55e),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Large side-by-side icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LargeIconBox(
                icon: activeIcon,
                label: activeSet.shortName,
                borderColor: accentColor,
                labelColor: accentColor,
              ),
              // VS divider
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  isSame ? '=' : 'vs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
              _LargeIconBox(
                icon: compareIcon,
                label: compareSet.shortName,
                borderColor: compareColor,
                labelColor: compareColor,
              ),
            ],
          ),
          // Codepoint detail for different icons
          if (!isSame) ...[
            const SizedBox(height: 8),
            Text(
              'U+${activeIcon.codePoint.toRadixString(16).toUpperCase()}'
              '  vs  '
              'U+${compareIcon.codePoint.toRadixString(16).toUpperCase()}',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Prev button
              GestureDetector(
                onTap: onPrev,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: onPrev != null
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: onPrev != null ? 0.12 : 0.04),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                    color: Colors.white
                        .withValues(alpha: onPrev != null ? 0.6 : 0.15),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Position counter
              Text(
                '${currentIndex + 1} / $totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 16),
              // Next button
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: onNext != null
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: onNext != null ? 0.12 : 0.04),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Colors.white
                        .withValues(alpha: onNext != null ? 0.6 : 0.15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeIconBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color borderColor;
  final Color labelColor;

  const _LargeIconBox({
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 72,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

// ─── Diff Summary ───────────────────────────────────────────────────────

class _DiffSummary extends StatelessWidget {
  final ProtoIconSet activeSet;
  final ProtoIconSet compareSet;
  final bool compact;

  const _DiffSummary({
    required this.activeSet,
    required this.compareSet,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeIcons = _showcaseIconList(activeSet);
    final compareIcons = _showcaseIconList(compareSet);

    // Filter to the compact set if needed
    final names = compact
        ? activeIcons
            .where(
                (e) => !const {'Add', 'Camera', 'Star', 'Tune'}.contains(e.$1))
            .toList()
        : activeIcons;

    int sameCount = 0;
    int diffCount = 0;
    for (final icon in names) {
      final compareIcon = compareIcons.firstWhere((c) => c.$1 == icon.$1);
      if (icon.$2.codePoint == compareIcon.$2.codePoint) {
        sameCount++;
      } else {
        diffCount++;
      }
    }

    final total = names.length;
    final allSame = diffCount == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: allSame
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFF22c55e).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: allSame
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF22c55e).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allSame ? Icons.check_circle_rounded : Icons.compare_arrows_rounded,
            size: 14,
            color: allSame
                ? Colors.white.withValues(alpha: 0.4)
                : const Color(0xFF22c55e),
          ),
          const SizedBox(width: 6),
          Text(
            allSame
                ? 'All $total icons identical'
                : '$diffCount of $total differ  ·  $sameCount identical',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: allSame
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFF22c55e).withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compare Chips ──────────────────────────────────────────────────────

class _CompareChips extends StatelessWidget {
  final int activeIndex;
  final int? compareIndex;
  final Color accentColor;
  final ValueChanged<int?> onChanged;

  const _CompareChips({
    required this.activeIndex,
    required this.compareIndex,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ChipButton(
          label: 'None',
          isSelected: compareIndex == null,
          isDisabled: false,
          accentColor: accentColor,
          onTap: () => onChanged(null),
        ),
        for (var i = 0; i < ProtoIconSet.all.length; i++)
          _ChipButton(
            label: ProtoIconSet.all[i].shortName,
            isSelected: compareIndex == i,
            isDisabled: i == activeIndex,
            accentColor: accentColor,
            onTap: () => onChanged(compareIndex == i ? null : i),
          ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final Color accentColor;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : Colors.white
                    .withValues(alpha: isDisabled ? 0.05 : 0.12),
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.2 : 1.0,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Narrative Comparison Helpers ────────────────────────────────────────

class _NarrativeComparison extends StatelessWidget {
  final String title;
  final String activeText;
  final String? activeLabel;
  final Color accentColor;
  final String? compareText;
  final String? compareLabel;

  const _NarrativeComparison({
    required this.title,
    required this.activeText,
    this.activeLabel,
    required this.accentColor,
    this.compareText,
    this.compareLabel,
  });

  static const _compareColor = Color(0xFF8b95a5);

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _DotLabel(label: activeLabel!, color: accentColor),
            ),
          Text(
            activeText,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (compareText != null) ...[
            const SizedBox(height: 16),
            _DotLabel(label: compareLabel!, color: _compareColor),
            const SizedBox(height: 6),
            Text(
              compareText!,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _DotLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _NarrativeLabel extends StatelessWidget {
  final String? label;
  final Color color;
  final Widget child;

  const _NarrativeLabel({
    this.label,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DotLabel(label: label!, color: color),
        const SizedBox(height: 6),
        child,
      ],
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

// ─── 3x3 Swatch Grid ────────────────────────────────────────────────────

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
      spacing: 12,
      runSpacing: 12,
      children: swatches
          .map((s) => _ColorSwatch(label: s.$1, color: s.$2))
          .toList(),
    );
  }
}

// ─── Harmony Circles ─────────────────────────────────────────────────────

class _HarmonyCircles extends StatelessWidget {
  final ProtoTheme theme;

  const _HarmonyCircles({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = [
      theme.primary,
      theme.secondary,
      theme.accent,
      theme.tertiary,
    ];

    return SizedBox(
      height: 36,
      child: Row(
        children: List.generate(colors.length, (i) {
          return Align(
            widthFactor: 0.7,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF16161e),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[i].withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Contrast Badge ──────────────────────────────────────────────────────

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
        // Mini preview
        Container(
          width: 28,
          height: 20,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Center(
            child: Text(
              'Aa',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
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
              color: passed
                  ? const Color(0xFF22c55e)
                  : const Color(0xFFf59e0b),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _copied
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
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
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (i) {
                final filled = i < score;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18,
                    color: filled ? color : Colors.white.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),
          ),
          Text(
            '$score/5',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
