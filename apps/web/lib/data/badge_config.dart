enum BadgeSize { large, small }
enum BadgePosition { top, bottom }
enum BadgeColorMode { themeColor, red }
enum BadgeStyle { prominent, subtle }
enum IndicatorPosition { top, bottom }

class BadgeConfig {
  final BadgeSize verifiedSize;
  final BadgePosition verifiedPosition;
  final BadgeColorMode verifiedColor;
  final BadgeSize matchSize;
  final BadgeStyle matchStyle;
  final IndicatorPosition photoIndicators;
  final bool showNavLabels;
  final BadgeSize distanceSize;

  const BadgeConfig({
    this.verifiedSize = BadgeSize.large,
    this.verifiedPosition = BadgePosition.top,
    this.verifiedColor = BadgeColorMode.themeColor,
    this.matchSize = BadgeSize.large,
    this.matchStyle = BadgeStyle.prominent,
    this.photoIndicators = IndicatorPosition.top,
    this.showNavLabels = true,
    this.distanceSize = BadgeSize.large,
  });

  factory BadgeConfig.original() => const BadgeConfig();

  factory BadgeConfig.neilMode() => const BadgeConfig(
        verifiedSize: BadgeSize.small,
        verifiedPosition: BadgePosition.bottom,
        verifiedColor: BadgeColorMode.red,
        matchSize: BadgeSize.small,
        matchStyle: BadgeStyle.subtle,
        photoIndicators: IndicatorPosition.bottom,
        showNavLabels: false,
        distanceSize: BadgeSize.small,
      );

  bool get isNeilMode =>
      verifiedSize == BadgeSize.small &&
      verifiedPosition == BadgePosition.bottom &&
      verifiedColor == BadgeColorMode.red &&
      matchSize == BadgeSize.small &&
      matchStyle == BadgeStyle.subtle &&
      photoIndicators == IndicatorPosition.bottom &&
      showNavLabels == false &&
      distanceSize == BadgeSize.small;

  BadgeConfig copyWith({
    BadgeSize? verifiedSize,
    BadgePosition? verifiedPosition,
    BadgeColorMode? verifiedColor,
    BadgeSize? matchSize,
    BadgeStyle? matchStyle,
    IndicatorPosition? photoIndicators,
    bool? showNavLabels,
    BadgeSize? distanceSize,
  }) {
    return BadgeConfig(
      verifiedSize: verifiedSize ?? this.verifiedSize,
      verifiedPosition: verifiedPosition ?? this.verifiedPosition,
      verifiedColor: verifiedColor ?? this.verifiedColor,
      matchSize: matchSize ?? this.matchSize,
      matchStyle: matchStyle ?? this.matchStyle,
      photoIndicators: photoIndicators ?? this.photoIndicators,
      showNavLabels: showNavLabels ?? this.showNavLabels,
      distanceSize: distanceSize ?? this.distanceSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeConfig &&
          runtimeType == other.runtimeType &&
          verifiedSize == other.verifiedSize &&
          verifiedPosition == other.verifiedPosition &&
          verifiedColor == other.verifiedColor &&
          matchSize == other.matchSize &&
          matchStyle == other.matchStyle &&
          photoIndicators == other.photoIndicators &&
          showNavLabels == other.showNavLabels &&
          distanceSize == other.distanceSize;

  @override
  int get hashCode => Object.hash(
        verifiedSize,
        verifiedPosition,
        verifiedColor,
        matchSize,
        matchStyle,
        photoIndicators,
        showNavLabels,
        distanceSize,
      );
}
