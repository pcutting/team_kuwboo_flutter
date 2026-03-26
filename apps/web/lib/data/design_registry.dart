import 'package:flutter/material.dart';

// Metadata (shared across sets)
import '../v0-urban-warmth/metadata.dart' as v0_meta;
import '../v2-soft-luxury/metadata.dart' as v2_meta;
import '../v3-vibrant-pop/metadata.dart' as v3_meta;
import '../v4-dark-mode-native/metadata.dart' as v4_meta;
import '../v5-organic-warmth/metadata.dart' as v5_meta;
import '../v6-minimal-swiss/metadata.dart' as v6_meta;
import '../v9-hyper-local-street/metadata.dart' as v9_meta;
import '../v10-calm-tech/metadata.dart' as v10_meta;

// Set C design versions — 8 designs with custom screens
import '../set-c/v0-urban-warmth/dating_profile_card.dart' as v0c;
import '../set-c/v0-urban-warmth/yoyo_nearby.dart' as v0c_yoyo;
import '../set-c/v0-urban-warmth/video_feed.dart' as v0c_video;
import '../set-c/v0-urban-warmth/social_feed.dart' as v0c_social;
import '../set-c/v0-urban-warmth/market_browse.dart' as v0c_market;
import '../set-c/v2-soft-luxury/dating_profile_card.dart' as v2c;
import '../set-c/v2-soft-luxury/yoyo_nearby.dart' as v2c_yoyo;
import '../set-c/v2-soft-luxury/video_feed.dart' as v2c_video;
import '../set-c/v2-soft-luxury/social_feed.dart' as v2c_social;
import '../set-c/v2-soft-luxury/market_browse.dart' as v2c_market;
import '../set-c/v3-vibrant-pop/dating_profile_card.dart' as v3c;
import '../set-c/v3-vibrant-pop/yoyo_nearby.dart' as v3c_yoyo;
import '../set-c/v3-vibrant-pop/video_feed.dart' as v3c_video;
import '../set-c/v3-vibrant-pop/social_feed.dart' as v3c_social;
import '../set-c/v3-vibrant-pop/market_browse.dart' as v3c_market;
import '../set-c/v4-dark-mode-native/dating_profile_card.dart' as v4c;
import '../set-c/v4-dark-mode-native/yoyo_nearby.dart' as v4c_yoyo;
import '../set-c/v4-dark-mode-native/video_feed.dart' as v4c_video;
import '../set-c/v4-dark-mode-native/social_feed.dart' as v4c_social;
import '../set-c/v4-dark-mode-native/market_browse.dart' as v4c_market;
import '../set-c/v5-organic-warmth/dating_profile_card.dart' as v5c;
import '../set-c/v5-organic-warmth/yoyo_nearby.dart' as v5c_yoyo;
import '../set-c/v5-organic-warmth/video_feed.dart' as v5c_video;
import '../set-c/v5-organic-warmth/social_feed.dart' as v5c_social;
import '../set-c/v5-organic-warmth/market_browse.dart' as v5c_market;
import '../set-c/v6-minimal-swiss/dating_profile_card.dart' as v6c;
import '../set-c/v6-minimal-swiss/yoyo_nearby.dart' as v6c_yoyo;
import '../set-c/v6-minimal-swiss/video_feed.dart' as v6c_video;
import '../set-c/v6-minimal-swiss/social_feed.dart' as v6c_social;
import '../set-c/v6-minimal-swiss/market_browse.dart' as v6c_market;
import '../set-c/v9-hyper-local-street/dating_profile_card.dart' as v9c;
import '../set-c/v9-hyper-local-street/yoyo_nearby.dart' as v9c_yoyo;
import '../set-c/v9-hyper-local-street/video_feed.dart' as v9c_video;
import '../set-c/v9-hyper-local-street/social_feed.dart' as v9c_social;
import '../set-c/v9-hyper-local-street/market_browse.dart' as v9c_market;
import '../set-c/v10-calm-tech/dating_profile_card.dart' as v10c;
import '../set-c/v10-calm-tech/yoyo_nearby.dart' as v10c_yoyo;
import '../set-c/v10-calm-tech/video_feed.dart' as v10c_video;
import '../set-c/v10-calm-tech/social_feed.dart' as v10c_social;
import '../set-c/v10-calm-tech/market_browse.dart' as v10c_market;

/// Which design set is active
enum DesignSet {
  setC, // Bottom-right FAB service switcher
}

class DesignPalette {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;

  const DesignPalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
  });
}

class DesignTypography {
  final String headline;
  final String body;

  const DesignTypography({
    required this.headline,
    required this.body,
  });
}

class DesignScores {
  final int distinctiveness;
  final int coherence;
  final int usability;
  final int targetFit;
  final int longevity;

  const DesignScores({
    required this.distinctiveness,
    required this.coherence,
    required this.usability,
    required this.targetFit,
    required this.longevity,
  });

  double get overall =>
      (distinctiveness + coherence + usability + targetFit + longevity) / 5;
}

class DesignCritique {
  final String works;
  final String weakness;

  const DesignCritique({
    required this.works,
    required this.weakness,
  });
}

class DesignMetadata {
  final String name;
  final String shortName;
  final String target;
  final String philosophy;
  final DesignPalette palette;
  final DesignTypography typography;
  final List<String> keyElements;
  final DesignScores scores;
  final DesignCritique critique;
  final Widget datingCard;
  final Widget yoyoNearby;
  final Widget? videoFeed;
  final Widget? socialFeed;
  final Widget? marketBrowse;
  final bool isConfigurable;

  const DesignMetadata({
    required this.name,
    required this.shortName,
    required this.target,
    required this.philosophy,
    required this.palette,
    required this.typography,
    required this.keyElements,
    required this.scores,
    required this.critique,
    required this.datingCard,
    required this.yoyoNearby,
    this.videoFeed,
    this.socialFeed,
    this.marketBrowse,
    this.isConfigurable = false,
  });
}

DesignMetadata _buildDesign({
  required String designName,
  required String shortName,
  required String target,
  required String philosophy,
  required Color primaryColor,
  required Color secondaryColor,
  required Color backgroundColor,
  required Color surfaceColor,
  required Color textColor,
  required String headlineFont,
  required String bodyFont,
  required List<String> keyElements,
  required int distinctiveness,
  required int coherence,
  required int usability,
  required int targetFit,
  required int longevity,
  required String works,
  required String weakness,
  required Widget datingCard,
  required Widget yoyoNearby,
  Widget? videoFeed,
  Widget? socialFeed,
  Widget? marketBrowse,
  bool isConfigurable = false,
}) {
  return DesignMetadata(
    name: designName,
    shortName: shortName,
    target: target,
    philosophy: philosophy,
    palette: DesignPalette(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      text: textColor,
    ),
    typography: DesignTypography(
      headline: headlineFont,
      body: bodyFont,
    ),
    keyElements: keyElements,
    scores: DesignScores(
      distinctiveness: distinctiveness,
      coherence: coherence,
      usability: usability,
      targetFit: targetFit,
      longevity: longevity,
    ),
    critique: DesignCritique(
      works: works,
      weakness: weakness,
    ),
    datingCard: datingCard,
    yoyoNearby: yoyoNearby,
    videoFeed: videoFeed,
    socialFeed: socialFeed,
    marketBrowse: marketBrowse,
    isConfigurable: isConfigurable,
  );
}

// ─── Registry ───────────────────────────────────────────────────────────

class DesignRegistry {
  /// Design indices to hide from the viewer.
  /// Kept: 0 (Urban Warmth), 3 (Dark Mode), 4 (Organic Warmth), 6 (Street)
  /// Hidden: 1 (Soft Luxury), 2 (Vibrant Pop), 5 (Minimal Swiss), 7 (Calm Tech)
  static const _hiddenDesignIndices = {1, 2, 5, 7};

  /// Get designs for a specific set
  static List<DesignMetadata> getDesigns(DesignSet set) {
    switch (set) {
      case DesignSet.setC: return _buildSetC();
    }
  }

  /// Get all designs including hidden ones (for index mapping)
  static List<DesignMetadata> getAllDesigns(DesignSet set) {
    switch (set) {
      case DesignSet.setC: return _buildAllSetC();
    }
  }

  /// The original indices of the visible designs in _buildAllSetC()
  static List<int> get visibleOriginalIndices {
    final all = _buildAllSetC();
    return [
      for (int i = 0; i < all.length; i++)
        if (!_hiddenDesignIndices.contains(i)) i,
    ];
  }

  /// Set C: Visible designs only (filtered)
  static List<DesignMetadata> _buildSetC() {
    final all = _buildAllSetC();
    return [
      for (int i = 0; i < all.length; i++)
        if (!_hiddenDesignIndices.contains(i)) all[i],
    ];
  }

  /// Set C: All 8 designs (unfiltered, for theme index mapping)
  static List<DesignMetadata> _buildAllSetC() {
    return [
      _buildDesign(
        designName: v0_meta.designName, shortName: v0_meta.shortName, target: v0_meta.target, philosophy: v0_meta.philosophy,
        primaryColor: v0_meta.primaryColor, secondaryColor: v0_meta.secondaryColor, backgroundColor: v0_meta.backgroundColor,
        surfaceColor: v0_meta.surfaceColor, textColor: v0_meta.textColor, headlineFont: v0_meta.headlineFont, bodyFont: v0_meta.bodyFont,
        keyElements: v0_meta.keyElements, distinctiveness: v0_meta.distinctiveness, coherence: v0_meta.coherence,
        usability: v0_meta.usability, targetFit: v0_meta.targetFit, longevity: v0_meta.longevity, works: v0_meta.works, weakness: v0_meta.weakness,
        datingCard: const v0c.DatingProfileCard(), yoyoNearby: const v0c_yoyo.YoyoNearby(),
        videoFeed: const v0c_video.VideoFeed(), socialFeed: const v0c_social.SocialFeed(), marketBrowse: const v0c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v2_meta.designName, shortName: v2_meta.shortName, target: v2_meta.target, philosophy: v2_meta.philosophy,
        primaryColor: v2_meta.primaryColor, secondaryColor: v2_meta.secondaryColor, backgroundColor: v2_meta.backgroundColor,
        surfaceColor: v2_meta.surfaceColor, textColor: v2_meta.textColor, headlineFont: v2_meta.headlineFont, bodyFont: v2_meta.bodyFont,
        keyElements: v2_meta.keyElements, distinctiveness: v2_meta.distinctiveness, coherence: v2_meta.coherence,
        usability: v2_meta.usability, targetFit: v2_meta.targetFit, longevity: v2_meta.longevity, works: v2_meta.works, weakness: v2_meta.weakness,
        datingCard: const v2c.DatingProfileCard(), yoyoNearby: const v2c_yoyo.YoyoNearby(),
        videoFeed: const v2c_video.VideoFeed(), socialFeed: const v2c_social.SocialFeed(), marketBrowse: const v2c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v3_meta.designName, shortName: v3_meta.shortName, target: v3_meta.target, philosophy: v3_meta.philosophy,
        primaryColor: v3_meta.primaryColor, secondaryColor: v3_meta.secondaryColor, backgroundColor: v3_meta.backgroundColor,
        surfaceColor: v3_meta.surfaceColor, textColor: v3_meta.textColor, headlineFont: v3_meta.headlineFont, bodyFont: v3_meta.bodyFont,
        keyElements: v3_meta.keyElements, distinctiveness: v3_meta.distinctiveness, coherence: v3_meta.coherence,
        usability: v3_meta.usability, targetFit: v3_meta.targetFit, longevity: v3_meta.longevity, works: v3_meta.works, weakness: v3_meta.weakness,
        datingCard: const v3c.DatingProfileCard(), yoyoNearby: const v3c_yoyo.YoyoNearby(),
        videoFeed: const v3c_video.VideoFeed(), socialFeed: const v3c_social.SocialFeed(), marketBrowse: const v3c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v4_meta.designName, shortName: v4_meta.shortName, target: v4_meta.target, philosophy: v4_meta.philosophy,
        primaryColor: v4_meta.primaryColor, secondaryColor: v4_meta.secondaryColor, backgroundColor: v4_meta.backgroundColor,
        surfaceColor: v4_meta.surfaceColor, textColor: v4_meta.textColor, headlineFont: v4_meta.headlineFont, bodyFont: v4_meta.bodyFont,
        keyElements: v4_meta.keyElements, distinctiveness: v4_meta.distinctiveness, coherence: v4_meta.coherence,
        usability: v4_meta.usability, targetFit: v4_meta.targetFit, longevity: v4_meta.longevity, works: v4_meta.works, weakness: v4_meta.weakness,
        datingCard: const v4c.DatingProfileCard(), yoyoNearby: const v4c_yoyo.YoyoNearby(),
        videoFeed: const v4c_video.VideoFeed(), socialFeed: const v4c_social.SocialFeed(), marketBrowse: const v4c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v5_meta.designName, shortName: v5_meta.shortName, target: v5_meta.target, philosophy: v5_meta.philosophy,
        primaryColor: v5_meta.primaryColor, secondaryColor: v5_meta.secondaryColor, backgroundColor: v5_meta.backgroundColor,
        surfaceColor: v5_meta.surfaceColor, textColor: v5_meta.textColor, headlineFont: v5_meta.headlineFont, bodyFont: v5_meta.bodyFont,
        keyElements: v5_meta.keyElements, distinctiveness: v5_meta.distinctiveness, coherence: v5_meta.coherence,
        usability: v5_meta.usability, targetFit: v5_meta.targetFit, longevity: v5_meta.longevity, works: v5_meta.works, weakness: v5_meta.weakness,
        datingCard: const v5c.DatingProfileCard(), yoyoNearby: const v5c_yoyo.YoyoNearby(),
        videoFeed: const v5c_video.VideoFeed(), socialFeed: const v5c_social.SocialFeed(), marketBrowse: const v5c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v6_meta.designName, shortName: v6_meta.shortName, target: v6_meta.target, philosophy: v6_meta.philosophy,
        primaryColor: v6_meta.primaryColor, secondaryColor: v6_meta.secondaryColor, backgroundColor: v6_meta.backgroundColor,
        surfaceColor: v6_meta.surfaceColor, textColor: v6_meta.textColor, headlineFont: v6_meta.headlineFont, bodyFont: v6_meta.bodyFont,
        keyElements: v6_meta.keyElements, distinctiveness: v6_meta.distinctiveness, coherence: v6_meta.coherence,
        usability: v6_meta.usability, targetFit: v6_meta.targetFit, longevity: v6_meta.longevity, works: v6_meta.works, weakness: v6_meta.weakness,
        datingCard: const v6c.DatingProfileCard(), yoyoNearby: const v6c_yoyo.YoyoNearby(),
        videoFeed: const v6c_video.VideoFeed(), socialFeed: const v6c_social.SocialFeed(), marketBrowse: const v6c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v9_meta.designName, shortName: v9_meta.shortName, target: v9_meta.target, philosophy: v9_meta.philosophy,
        primaryColor: v9_meta.primaryColor, secondaryColor: v9_meta.secondaryColor, backgroundColor: v9_meta.backgroundColor,
        surfaceColor: v9_meta.surfaceColor, textColor: v9_meta.textColor, headlineFont: v9_meta.headlineFont, bodyFont: v9_meta.bodyFont,
        keyElements: v9_meta.keyElements, distinctiveness: v9_meta.distinctiveness, coherence: v9_meta.coherence,
        usability: v9_meta.usability, targetFit: v9_meta.targetFit, longevity: v9_meta.longevity, works: v9_meta.works, weakness: v9_meta.weakness,
        datingCard: const v9c.DatingProfileCard(), yoyoNearby: const v9c_yoyo.YoyoNearby(),
        videoFeed: const v9c_video.VideoFeed(), socialFeed: const v9c_social.SocialFeed(), marketBrowse: const v9c_market.MarketBrowse(),
      ),
      _buildDesign(
        designName: v10_meta.designName, shortName: v10_meta.shortName, target: v10_meta.target, philosophy: v10_meta.philosophy,
        primaryColor: v10_meta.primaryColor, secondaryColor: v10_meta.secondaryColor, backgroundColor: v10_meta.backgroundColor,
        surfaceColor: v10_meta.surfaceColor, textColor: v10_meta.textColor, headlineFont: v10_meta.headlineFont, bodyFont: v10_meta.bodyFont,
        keyElements: v10_meta.keyElements, distinctiveness: v10_meta.distinctiveness, coherence: v10_meta.coherence,
        usability: v10_meta.usability, targetFit: v10_meta.targetFit, longevity: v10_meta.longevity, works: v10_meta.works, weakness: v10_meta.weakness,
        datingCard: const v10c.DatingProfileCard(), yoyoNearby: const v10c_yoyo.YoyoNearby(),
        videoFeed: const v10c_video.VideoFeed(), socialFeed: const v10c_social.SocialFeed(), marketBrowse: const v10c_market.MarketBrowse(),
      ),
    ];
  }
}
