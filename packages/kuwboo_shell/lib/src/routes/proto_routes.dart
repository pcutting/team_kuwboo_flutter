/// Route name constants and GoRouter configuration for the Kuwboo prototype.
///
/// All routes are defined here as a single flat namespace.
/// Screen widgets are NOT imported here — route-to-screen binding
/// happens in each app's router setup (apps/mobile, apps/web).
class ProtoRoutes {
  ProtoRoutes._();

  // ── Module homes ──────────────────────────────────────────────────────
  static const videoFeed = '/video/feed';
  static const datingCards = '/dating/cards';
  static const yoyoNearby = '/yoyo/nearby';
  static const socialFeed = '/social/feed';
  static const shopBrowse = '/shop/browse';

  // ── Video ─────────────────────────────────────────────────────────────
  static const videoFollowing = '/video/following';
  static const videoComments = '/video/comments';
  static const videoRecord = '/video/record';
  static const videoEdit = '/video/edit';
  static const videoCreator = '/video/creator';
  static const videoDiscover = '/video/discover';
  static const videoSound = '/video/sound';

  // ── Dating ────────────────────────────────────────────────────────────
  static const datingProfile = '/dating/profile';
  static const datingMatch = '/dating/match';
  static const datingMatches = '/dating/matches';
  static const datingFilters = '/dating/filters';
  static const datingLikes = '/dating/likes';
  static const datingChat = '/dating/chat';

  // ── Social ────────────────────────────────────────────────────────────
  static const socialStumble = '/social/stumble';
  static const socialCompose = '/social/compose';
  static const socialStory = '/social/story';
  static const socialFriends = '/social/friends';
  static const socialEvents = '/social/events';

  // ── Shop ──────────────────────────────────────────────────────────────
  static const shopProduct = '/shop/product';
  static const shopCreate = '/shop/create';
  static const shopSeller = '/shop/seller';
  static const shopDeals = '/shop/deals';
  static const shopMessages = '/shop/messages';
  static const shopAuction = '/shop/auction';

  // ── YoYo ──────────────────────────────────────────────────────────────
  static const yoyoProfile = '/yoyo/profile';
  static const yoyoConnect = '/yoyo/connect';
  static const yoyoWave = '/yoyo/wave';
  static const yoyoChat = '/yoyo/chat';
  static const yoyoSettings = '/yoyo/settings';
  static const yoyoFilters = '/yoyo/filters';

  // ── Chat ──────────────────────────────────────────────────────────────
  static const chatInbox = '/chat/inbox';
  static const chatConversation = '/chat/conversation';

  // ── Profile ───────────────────────────────────────────────────────────
  static const profileMy = '/profile/my';
  static const profileEdit = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const profileNotifications = '/profile/notifications';

  // ── Auth ───────────────────────────────────────────────────────────────
  static const authWelcome = '/auth/welcome';
  static const authOnboarding = '/auth/onboarding';
  static const authTutorial = '/auth/tutorial';
  static const authMethod = '/auth/method';
  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authBirthday = '/auth/birthday';
  static const authProfile = '/auth/profile';
  static const authLogin = '/auth/login';
  static const authEmailRegister = '/auth/email/register';
  static const authEmailLogin = '/auth/email/login';
  static const authEmailPasswordForgot = '/auth/email/password/forgot';
  static const authEmailPasswordReset = '/auth/email/password/reset';
  static const authAgeBlock = '/auth/age-block';

  // ── Legal ─────────────────────────────────────────────────────────────
  static const legalTerms = '/legal/terms';
  static const legalPrivacy = '/legal/privacy';

  // ── Sponsored ─────────────────────────────────────────────────────────
  static const sponsoredInline = '/sponsored/inline';
  static const sponsoredHub = '/sponsored/hub';
  static const sponsoredCreate = '/sponsored/create';
  static const sponsoredCampaign = '/sponsored/campaign';

  /// Home route for each module (tab 0).
  static String homeRoute(String module) {
    switch (module) {
      case 'video':
        return videoFeed;
      case 'dating':
        return datingCards;
      case 'yoyo':
        return yoyoNearby;
      case 'social':
        return socialFeed;
      case 'shop':
        return shopBrowse;
      default:
        return yoyoNearby;
    }
  }

  /// Maps (module, tabIndex) → route path for bottom nav tab switching.
  static const tabRoutes = <String, List<String>>{
    'video': [videoFeed, videoFollowing, videoDiscover, videoRecord],
    'dating': [datingCards, datingMatches, datingLikes, datingChat],
    'yoyo': [yoyoNearby, yoyoConnect, yoyoWave, yoyoChat],
    'social': [socialFeed, socialFriends, socialEvents, socialCompose],
    'shop': [shopBrowse, shopDeals, shopCreate, chatInbox],
  };

  /// Get the route for a specific module tab.
  static String? tabRoute(String module, int tabIndex) {
    final routes = tabRoutes[module];
    if (routes == null || tabIndex < 0 || tabIndex >= routes.length) {
      return null;
    }
    return routes[tabIndex];
  }
}
