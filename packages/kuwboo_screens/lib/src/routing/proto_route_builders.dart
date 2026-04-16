import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_chat/kuwboo_chat.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../dating/dating_card_stack.dart';
import '../dating/dating_expanded_profile.dart';
import '../dating/dating_filters_sheet.dart';
import '../dating/dating_likes_screen.dart';
import '../dating/dating_match_overlay.dart';
import '../dating/dating_matches_list.dart';
import '../profile/profile_edit_screen.dart';
import '../profile/profile_my_screen.dart';
import '../profile/profile_notifications_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../shop/shop_auction_detail.dart';
import '../shop/shop_browse_screen.dart';
import '../shop/shop_create_listing.dart';
import '../shop/shop_deals_screen.dart';
import '../shop/shop_product_detail.dart';
import '../shop/shop_seller_profile.dart';
import '../social/social_composer_screen.dart';
import '../social/social_events_screen.dart';
import '../social/social_feed_screen.dart';
import '../social/social_friends_list.dart';
import '../social/social_story_viewer.dart';
import '../social/social_stumble_screen.dart';
import '../sponsored/sponsored_campaign_detail.dart';
import '../sponsored/sponsored_create_campaign.dart';
import '../sponsored/sponsored_hub.dart';
import '../video/video_creator_profile.dart';
import '../video/video_comments_sheet.dart';
import '../video/video_discover_screen.dart';
import '../video/video_edit_screen.dart';
import '../video/video_feed_screen.dart';
import '../video/video_recording_screen.dart';
import '../video/video_sound_screen.dart';
import '../yoyo/yoyo_connect_screen.dart';
import '../yoyo/yoyo_filter_sheet.dart';
import '../yoyo/yoyo_nearby_screen.dart';
import '../yoyo/yoyo_settings_screen.dart';
import '../yoyo/yoyo_user_profile.dart';
import '../yoyo/yoyo_wave_screen.dart';

/// Shell routes shared by the web prototype and mobile apps.
///
/// These routes are designed to sit inside a [ShellRoute] so the active screen
/// is wrapped by [ProtoScaffold]. Apps can override platform-specific screens
/// by passing widget builders — `null` means use the default (web) screen.
List<RouteBase> buildProtoShellRoutes({
  Widget Function()? yoyoNearbyOverride,
  Widget Function()? videoFeedOverride,
  Widget Function()? socialFeedOverride,
  Widget Function()? shopBrowseOverride,
}) {
  Widget yoyoNearby() =>
      yoyoNearbyOverride?.call() ?? const YoyoNearbyScreen();
  Widget videoFeed() =>
      videoFeedOverride?.call() ?? const VideoFeedScreen();
  Widget socialFeed() =>
      socialFeedOverride?.call() ?? const SocialFeedScreen();
  Widget shopBrowse() =>
      shopBrowseOverride?.call() ?? const ShopBrowseScreen();

  return <RouteBase>[
    // YoYo
    GoRoute(
      path: ProtoRoutes.yoyoNearby,
      pageBuilder: (c, s) => NoTransitionPage(child: yoyoNearby()),
    ),
    GoRoute(
      path: ProtoRoutes.yoyoConnect,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: YoyoConnectScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.yoyoWave,
      pageBuilder: (c, s) => const NoTransitionPage(child: YoyoWaveScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.yoyoChat,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: ChatInboxScreen(moduleKey: 'YoYo')),
    ),
    // Video
    GoRoute(
      path: ProtoRoutes.videoFeed,
      pageBuilder: (c, s) => NoTransitionPage(child: videoFeed()),
    ),
    GoRoute(
      path: ProtoRoutes.videoFollowing,
      pageBuilder: (c, s) => const NoTransitionPage(
        child: VideoFeedScreen(isFollowingFeed: true),
      ),
    ),
    GoRoute(
      path: ProtoRoutes.videoDiscover,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: VideoDiscoverScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.videoRecord,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: VideoRecordingScreen()),
    ),
    // Dating
    GoRoute(
      path: ProtoRoutes.datingCards,
      pageBuilder: (c, s) => const NoTransitionPage(child: DatingCardStack()),
    ),
    GoRoute(
      path: ProtoRoutes.datingMatches,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: DatingMatchesList()),
    ),
    GoRoute(
      path: ProtoRoutes.datingLikes,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: DatingLikesScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.datingChat,
      pageBuilder: (c, s) => const NoTransitionPage(
        child: ChatInboxScreen(moduleKey: 'Dating'),
      ),
    ),
    // Social
    GoRoute(
      path: ProtoRoutes.socialFeed,
      pageBuilder: (c, s) => NoTransitionPage(child: socialFeed()),
    ),
    GoRoute(
      path: ProtoRoutes.socialFriends,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: SocialFriendsList()),
    ),
    GoRoute(
      path: ProtoRoutes.socialEvents,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: SocialEventsScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.socialCompose,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: SocialComposerScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.socialStumble,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: SocialStumbleScreen()),
    ),
    // Shop
    GoRoute(
      path: ProtoRoutes.shopBrowse,
      pageBuilder: (c, s) => NoTransitionPage(child: shopBrowse()),
    ),
    GoRoute(
      path: ProtoRoutes.shopDeals,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: ShopDealsScreen()),
    ),
    GoRoute(
      path: ProtoRoutes.shopCreate,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: ShopCreateListing()),
    ),
    GoRoute(
      path: ProtoRoutes.shopMessages,
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: ChatInboxScreen(moduleKey: 'Shop')),
    ),
    GoRoute(
      path: ProtoRoutes.chatInbox,
      pageBuilder: (c, s) => const NoTransitionPage(child: ChatInboxScreen()),
    ),
  ];
}

/// Modal routes rooted on the app's root navigator. Spread after the
/// [ShellRoute] so they push on top of the shell.
List<RouteBase> buildProtoModalRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return <RouteBase>[
    GoRoute(
      path: ProtoRoutes.yoyoSettings,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const YoyoSettingsScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.yoyoProfile,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const YoyoUserProfile(),
    ),
    GoRoute(
      path: ProtoRoutes.yoyoFilters,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const YoyoFilterSheet(),
    ),
    GoRoute(
      path: ProtoRoutes.videoComments,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const VideoCommentsSheet(),
    ),
    GoRoute(
      path: ProtoRoutes.videoEdit,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const VideoEditScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.videoCreator,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const VideoCreatorProfile(),
    ),
    GoRoute(
      path: ProtoRoutes.videoSound,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const VideoSoundScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.datingProfile,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const DatingExpandedProfile(),
    ),
    GoRoute(
      path: ProtoRoutes.datingMatch,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const DatingMatchOverlay(),
    ),
    GoRoute(
      path: ProtoRoutes.datingFilters,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const DatingFiltersSheet(),
    ),
    GoRoute(
      path: ProtoRoutes.shopProduct,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ShopProductDetail(),
    ),
    GoRoute(
      path: ProtoRoutes.shopSeller,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ShopSellerProfile(),
    ),
    GoRoute(
      path: ProtoRoutes.shopAuction,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ShopAuctionDetail(),
    ),
    GoRoute(
      path: ProtoRoutes.chatConversation,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ChatConversationScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.profileMy,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ProfileMyScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.profileEdit,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.profileSettings,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.profileNotifications,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const ProfileNotificationsScreen(),
    ),
    // Social story viewer (modal overlay)
    GoRoute(
      path: ProtoRoutes.socialStory,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const SocialStoryViewer(),
    ),
    // Sponsored (advertiser surfaces — modals)
    GoRoute(
      path: ProtoRoutes.sponsoredHub,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const SponsoredHub(),
    ),
    GoRoute(
      path: ProtoRoutes.sponsoredCreate,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const SponsoredCreateCampaign(),
    ),
    GoRoute(
      path: ProtoRoutes.sponsoredCampaign,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const SponsoredCampaignDetail(),
    ),
    // Auth prototype screens
    GoRoute(
      path: ProtoRoutes.authWelcome,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthWelcomeScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authOnboarding,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthOnboardingScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authTutorial,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthTutorialScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authMethod,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthMethodScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authLogin,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthLoginScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authPhone,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthPhoneScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authOtp,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => AuthOtpScreen(args: s.extra as AuthOtpArgs?),
    ),
    GoRoute(
      path: ProtoRoutes.authBirthday,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthBirthdayScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authProfile,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthProfileScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.authAgeBlock,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const AuthAgeBlockScreen(),
    ),
    // Legal placeholders — linked from the auth method screen. Final copy
    // pending from Neil; see legal_*_screen.dart TODO(legal) markers.
    GoRoute(
      path: ProtoRoutes.legalTerms,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const LegalTermsScreen(),
    ),
    GoRoute(
      path: ProtoRoutes.legalPrivacy,
      parentNavigatorKey: rootNavigatorKey,
      builder: (c, s) => const LegalPrivacyScreen(),
    ),
  ];
}
