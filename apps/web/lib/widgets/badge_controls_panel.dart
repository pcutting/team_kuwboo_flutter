import 'package:flutter/material.dart';
import '../data/badge_config.dart';
import '../data/badge_config_provider.dart';

class BadgeControlsPanel extends StatelessWidget {
  final ScrollController? scrollController;

  const BadgeControlsPanel({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final config = BadgeConfigProvider.of(context);
    final notifier = BadgeConfigProvider.notifierOf(context);

    return Container(
      color: const Color(0xFF16161e),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BADGE CONTROLS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),

            // Neil Mode master toggle
            _NeilModeToggle(
              isActive: config.isNeilMode,
              onToggle: () {
                notifier.value = config.isNeilMode
                    ? BadgeConfig.original()
                    : BadgeConfig.neilMode();
              },
            ),
            const SizedBox(height: 20),
            _divider(),

            // Verified Badge section
            const SizedBox(height: 16),
            _sectionLabel('VERIFIED BADGE'),
            const SizedBox(height: 10),
            _optionRow('Size', [
              _SegOption('Large', config.verifiedSize == BadgeSize.large),
              _SegOption('Small', config.verifiedSize == BadgeSize.small),
            ], (i) {
              notifier.value = config.copyWith(
                verifiedSize: i == 0 ? BadgeSize.large : BadgeSize.small,
              );
            }),
            const SizedBox(height: 8),
            _optionRow('Position', [
              _SegOption('Top', config.verifiedPosition == BadgePosition.top),
              _SegOption('Bottom', config.verifiedPosition == BadgePosition.bottom),
            ], (i) {
              notifier.value = config.copyWith(
                verifiedPosition: i == 0 ? BadgePosition.top : BadgePosition.bottom,
              );
            }),
            const SizedBox(height: 8),
            _optionRow('Color', [
              _SegOption('Theme', config.verifiedColor == BadgeColorMode.themeColor),
              _SegOption('Red', config.verifiedColor == BadgeColorMode.red),
            ], (i) {
              notifier.value = config.copyWith(
                verifiedColor: i == 0 ? BadgeColorMode.themeColor : BadgeColorMode.red,
              );
            }),
            const SizedBox(height: 16),
            _divider(),

            // Match Badge section
            const SizedBox(height: 16),
            _sectionLabel('MATCH BADGE'),
            const SizedBox(height: 10),
            _optionRow('Size', [
              _SegOption('Large', config.matchSize == BadgeSize.large),
              _SegOption('Small', config.matchSize == BadgeSize.small),
            ], (i) {
              notifier.value = config.copyWith(
                matchSize: i == 0 ? BadgeSize.large : BadgeSize.small,
              );
            }),
            const SizedBox(height: 8),
            _optionRow('Style', [
              _SegOption('Bold', config.matchStyle == BadgeStyle.prominent),
              _SegOption('Subtle', config.matchStyle == BadgeStyle.subtle),
            ], (i) {
              notifier.value = config.copyWith(
                matchStyle: i == 0 ? BadgeStyle.prominent : BadgeStyle.subtle,
              );
            }),
            const SizedBox(height: 16),
            _divider(),

            // Photo Indicators section
            const SizedBox(height: 16),
            _sectionLabel('PHOTO INDICATORS'),
            const SizedBox(height: 10),
            _optionRow('Position', [
              _SegOption('Top', config.photoIndicators == IndicatorPosition.top),
              _SegOption('Bottom', config.photoIndicators == IndicatorPosition.bottom),
            ], (i) {
              notifier.value = config.copyWith(
                photoIndicators: i == 0 ? IndicatorPosition.top : IndicatorPosition.bottom,
              );
            }),
            const SizedBox(height: 16),
            _divider(),

            // Distance section
            const SizedBox(height: 16),
            _sectionLabel('DISTANCE'),
            const SizedBox(height: 10),
            _optionRow('Size', [
              _SegOption('Normal', config.distanceSize == BadgeSize.large),
              _SegOption('Small', config.distanceSize == BadgeSize.small),
            ], (i) {
              notifier.value = config.copyWith(
                distanceSize: i == 0 ? BadgeSize.large : BadgeSize.small,
              );
            }),
            const SizedBox(height: 16),
            _divider(),

            // Navigation section
            const SizedBox(height: 16),
            _sectionLabel('NAVIGATION'),
            const SizedBox(height: 10),
            _optionRow('Labels', [
              _SegOption('Show', config.showNavLabels),
              _SegOption('Hide', !config.showNavLabels),
            ], (i) {
              notifier.value = config.copyWith(showNavLabels: i == 0);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  Widget _optionRow(
    String label,
    List<_SegOption> options,
    ValueChanged<int> onSelected,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: List.generate(options.length, (i) {
                final opt = options[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: opt.isSelected
                            ? const Color(0xFF7c3aed).withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: opt.isSelected
                            ? Border.all(
                                color: const Color(0xFF7c3aed),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        opt.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: opt.isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: opt.isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegOption {
  final String label;
  final bool isSelected;
  const _SegOption(this.label, this.isSelected);
}

class _NeilModeToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _NeilModeToggle({
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10b981).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF10b981)
                : Colors.white.withValues(alpha: 0.1),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 18,
              color: isActive
                  ? const Color(0xFF10b981)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'NEIL MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isActive
                      ? const Color(0xFF10b981)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10b981)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
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
