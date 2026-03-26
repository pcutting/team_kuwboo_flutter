import 'package:flutter/material.dart';
import 'proto_transitions.dart';

// Screen imports — home screens
import 'screens/video/video_feed_screen.dart';
import 'screens/dating/dating_card_stack.dart';
import 'screens/yoyo/yoyo_nearby_screen.dart';
import 'screens/social/social_feed_screen.dart';
import 'screens/shop/shop_browse_screen.dart';

// Video sub-screens
import 'screens/video/video_comments_sheet.dart';
import 'screens/video/video_recording_screen.dart';
import 'screens/video/video_edit_screen.dart';
import 'screens/video/video_creator_profile.dart';
import 'screens/video/video_discover_screen.dart';
import 'screens/video/video_sound_screen.dart';

// Dating sub-screens
import 'screens/dating/dating_expanded_profile.dart';
import 'screens/dating/dating_match_overlay.dart';
import 'screens/dating/dating_matches_list.dart';
import 'screens/dating/dating_filters_sheet.dart';
import 'screens/dating/dating_likes_screen.dart';
import 'screens/dating/dating_chat_screen.dart';

// Social sub-screens
import 'screens/social/social_stumble_screen.dart';
import 'screens/social/social_composer_screen.dart';
import 'screens/social/social_story_viewer.dart';
import 'screens/social/social_friends_list.dart';
import 'screens/social/social_events_screen.dart';

// Shop sub-screens
import 'screens/shop/shop_product_detail.dart';
import 'screens/shop/shop_create_listing.dart';
import 'screens/shop/shop_seller_profile.dart';
import 'screens/shop/shop_deals_screen.dart';
import 'screens/shop/shop_messages_screen.dart';
import 'screens/shop/shop_auction_detail.dart';

// YoYo sub-screens
import 'screens/yoyo/yoyo_user_profile.dart';
import 'screens/yoyo/yoyo_connect_screen.dart';
import 'screens/yoyo/yoyo_wave_screen.dart';
import 'screens/yoyo/yoyo_chat_screen.dart';
import 'screens/yoyo/yoyo_settings_screen.dart';
import 'screens/yoyo/yoyo_filter_sheet.dart';

// Chat
import 'screens/chat/chat_inbox_screen.dart';
import 'screens/chat/chat_conversation_screen.dart';

// Profile
import 'screens/profile/profile_my_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/profile/profile_settings_screen.dart';
import 'screens/profile/profile_notifications_screen.dart';

// Auth
import 'screens/auth/auth_welcome_screen.dart';
import 'screens/auth/auth_signup_screen.dart';
import 'screens/auth/auth_onboarding_screen.dart';
import 'screens/auth/auth_tutorial_screen.dart';
import 'screens/auth/auth_method_screen.dart';
import 'screens/auth/auth_phone_screen.dart';
import 'screens/auth/auth_otp_screen.dart';
import 'screens/auth/auth_birthday_screen.dart';
import 'screens/auth/auth_profile_screen.dart';
import 'screens/auth/auth_login_screen.dart';
import 'screens/auth/auth_age_block_screen.dart';

// Sponsored
import 'screens/sponsored/sponsored_inline.dart';
import 'screens/sponsored/sponsored_hub.dart';
import 'screens/sponsored/sponsored_create_campaign.dart';
import 'screens/sponsored/sponsored_campaign_detail.dart';

/// Route name constants
class ProtoRoutes {
  // Module homes
  static const videoFeed = '/video/feed';
  static const datingCards = '/dating/cards';
  static const yoyoNearby = '/yoyo/nearby';
  static const socialFeed = '/social/feed';
  static const shopBrowse = '/shop/browse';

  // Video
  static const videoFollowing = '/video/following';
  static const videoComments = '/video/comments';
  static const videoRecord = '/video/record';
  static const videoEdit = '/video/edit';
  static const videoCreator = '/video/creator';
  static const videoDiscover = '/video/discover';
  static const videoSound = '/video/sound';

  // Dating
  static const datingProfile = '/dating/profile';
  static const datingMatch = '/dating/match';
  static const datingMatches = '/dating/matches';
  static const datingFilters = '/dating/filters';
  static const datingLikes = '/dating/likes';
  static const datingChat = '/dating/chat';

  // Social
  static const socialStumble = '/social/stumble';
  static const socialCompose = '/social/compose';
  static const socialStory = '/social/story';
  static const socialFriends = '/social/friends';
  static const socialEvents = '/social/events';

  // Shop
  static const shopProduct = '/shop/product';
  static const shopCreate = '/shop/create';
  static const shopSeller = '/shop/seller';
  static const shopDeals = '/shop/deals';
  static const shopMessages = '/shop/messages';
  static const shopAuction = '/shop/auction';

  // YoYo
  static const yoyoProfile = '/yoyo/profile';
  static const yoyoConnect = '/yoyo/connect';
  static const yoyoWave = '/yoyo/wave';
  static const yoyoChat = '/yoyo/chat';
  static const yoyoSettings = '/yoyo/settings';
  static const yoyoFilters = '/yoyo/filters';

  // Chat
  static const chatInbox = '/chat/inbox';
  static const chatConversation = '/chat/conversation';

  // Profile
  static const profileMy = '/profile/my';
  static const profileEdit = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const profileNotifications = '/profile/notifications';

  // Auth
  static const authWelcome = '/auth/welcome';
  static const authSignup = '/auth/signup';
  static const authOnboarding = '/auth/onboarding';
  static const authTutorial = '/auth/tutorial';
  static const authMethod = '/auth/method';
  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authBirthday = '/auth/birthday';
  static const authProfile = '/auth/profile';
  static const authLogin = '/auth/login';
  static const authAgeBlock = '/auth/age-block';

  // Sponsored
  static const sponsoredInline = '/sponsored/inline';
  static const sponsoredHub = '/sponsored/hub';
  static const sponsoredCreate = '/sponsored/create';
  static const sponsoredCampaign = '/sponsored/campaign';
}

/// Route generator for the prototype's nested Navigator
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ── Root route (fallback for initial route splitting) ──
    case '/':
      return instant(const VideoFeedScreen(), name: ProtoRoutes.videoFeed);

    // ── Module homes (instant transition for bottom nav) ──
    case ProtoRoutes.videoFeed:
      return instant(const VideoFeedScreen(), name: settings.name);
    case ProtoRoutes.datingCards:
      return instant(const DatingCardStack(), name: settings.name);
    case ProtoRoutes.yoyoNearby:
      return instant(const YoyoNearbyScreen(), name: settings.name);
    case ProtoRoutes.socialFeed:
      return instant(const SocialFeedScreen(), name: settings.name);
    case ProtoRoutes.shopBrowse:
      return instant(const ShopBrowseScreen(), name: settings.name);

    case ProtoRoutes.videoFollowing:
      return instant(const VideoFeedScreen(isFollowingFeed: true), name: settings.name);

    // ── Video sub-screens ──
    case ProtoRoutes.videoComments:
      return slideUp(const VideoCommentsSheet(), name: settings.name);
    case ProtoRoutes.videoRecord:
      return instant(const VideoRecordingScreen(), name: settings.name);
    case ProtoRoutes.videoEdit:
      return slideRight(const VideoEditScreen(), name: settings.name);
    case ProtoRoutes.videoCreator:
      return slideRight(const VideoCreatorProfile(), name: settings.name);
    case ProtoRoutes.videoDiscover:
      return instant(const VideoDiscoverScreen(), name: settings.name);
    case ProtoRoutes.videoSound:
      return slideRight(const VideoSoundScreen(), name: settings.name);

    // ── Dating sub-screens ──
    case ProtoRoutes.datingProfile:
      return slideRight(const DatingExpandedProfile(), name: settings.name);
    case ProtoRoutes.datingMatch:
      return fade(const DatingMatchOverlay(), name: settings.name);
    case ProtoRoutes.datingMatches:
      return instant(const DatingMatchesList(), name: settings.name);
    case ProtoRoutes.datingFilters:
      return slideUp(const DatingFiltersSheet(), name: settings.name);
    case ProtoRoutes.datingLikes:
      return instant(const DatingLikesScreen(), name: settings.name);
    case ProtoRoutes.datingChat:
      return instant(const DatingChatScreen(), name: settings.name);

    // ── Social sub-screens ──
    case ProtoRoutes.socialStumble:
      return slideRight(const SocialStumbleScreen(), name: settings.name);
    case ProtoRoutes.socialCompose:
      final composeArgs = settings.arguments as Map<String, dynamic>?;
      return slideRight(SocialComposerScreen(repostVideoArgs: composeArgs), name: settings.name);
    case ProtoRoutes.socialStory:
      return fade(const SocialStoryViewer(), name: settings.name);
    case ProtoRoutes.socialFriends:
      return instant(const SocialFriendsList(), name: settings.name);
    case ProtoRoutes.socialEvents:
      return instant(const SocialEventsScreen(), name: settings.name);

    // ── Shop sub-screens ──
    case ProtoRoutes.shopProduct:
      return slideRight(const ShopProductDetail(), name: settings.name);
    case ProtoRoutes.shopCreate:
      return instant(const ShopCreateListing(), name: settings.name);
    case ProtoRoutes.shopSeller:
      return slideRight(const ShopSellerProfile(), name: settings.name);
    case ProtoRoutes.shopDeals:
      return instant(const ShopDealsScreen(), name: settings.name);
    case ProtoRoutes.shopMessages:
      return instant(const ShopMessagesScreen(), name: settings.name);
    case ProtoRoutes.shopAuction:
      return slideRight(const ShopAuctionDetail(), name: settings.name);

    // ── YoYo sub-screens ──
    case ProtoRoutes.yoyoProfile:
      return slideRight(const YoyoUserProfile(), name: settings.name);
    case ProtoRoutes.yoyoConnect:
      return instant(const YoyoConnectScreen(), name: settings.name);
    case ProtoRoutes.yoyoWave:
      return instant(const YoyoWaveScreen(), name: settings.name);
    case ProtoRoutes.yoyoChat:
      return instant(const YoyoChatScreen(), name: settings.name);
    case ProtoRoutes.yoyoSettings:
      return slideRight(const YoyoSettingsScreen(), name: settings.name);
    case ProtoRoutes.yoyoFilters:
      return slideUp(const YoyoFilterSheet(), name: settings.name);

    // ── Chat ──
    case ProtoRoutes.chatInbox:
      return slideRight(const ChatInboxScreen(), name: settings.name);
    case ProtoRoutes.chatConversation:
      final chatArgs = settings.arguments as Map<String, dynamic>?;
      return slideRight(
        ChatConversationScreen(initialVariant: chatArgs?['variant'] as int? ?? 0),
        name: settings.name,
      );

    // ── Profile ──
    case ProtoRoutes.profileMy:
      return slideRight(const ProfileMyScreen(), name: settings.name);
    case ProtoRoutes.profileEdit:
      return slideRight(const ProfileEditScreen(), name: settings.name);
    case ProtoRoutes.profileSettings:
      return slideRight(const ProfileSettingsScreen(), name: settings.name);
    case ProtoRoutes.profileNotifications:
      return slideRight(const ProfileNotificationsScreen(), name: settings.name);

    // ── Auth ──
    case ProtoRoutes.authWelcome:
      return slideRight(const AuthWelcomeScreen(), name: settings.name);
    case ProtoRoutes.authSignup:
      return slideRight(const AuthSignupScreen(), name: settings.name);
    case ProtoRoutes.authOnboarding:
      return slideRight(const AuthOnboardingScreen(), name: settings.name);
    case ProtoRoutes.authTutorial:
      return slideRight(const AuthTutorialScreen(), name: settings.name);
    case ProtoRoutes.authMethod:
      return slideRight(const AuthMethodScreen(), name: settings.name);
    case ProtoRoutes.authPhone:
      return slideRight(const AuthPhoneScreen(), name: settings.name);
    case ProtoRoutes.authOtp:
      return slideRight(const AuthOtpScreen(), name: settings.name);
    case ProtoRoutes.authBirthday:
      return slideRight(const AuthBirthdayScreen(), name: settings.name);
    case ProtoRoutes.authProfile:
      return slideRight(const AuthProfileScreen(), name: settings.name);
    case ProtoRoutes.authLogin:
      return slideRight(const AuthLoginScreen(), name: settings.name);
    case ProtoRoutes.authAgeBlock:
      return fade(const AuthAgeBlockScreen(), name: settings.name);

    // ── Sponsored ──
    case ProtoRoutes.sponsoredInline:
      return slideRight(const SponsoredInline(), name: settings.name);
    case ProtoRoutes.sponsoredHub:
      return slideRight(const SponsoredHub(), name: settings.name);
    case ProtoRoutes.sponsoredCreate:
      return slideRight(const SponsoredCreateCampaign(), name: settings.name);
    case ProtoRoutes.sponsoredCampaign:
      return slideRight(const SponsoredCampaignDetail(), name: settings.name);

    default:
      return instant(
        const Center(child: Text('Route not found')),
        name: settings.name,
      );
  }
}
