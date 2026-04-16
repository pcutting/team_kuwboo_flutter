/// Stable identifiers for interactive or assert-worthy widgets across
/// the feature screen modules (yoyo, video, dating, social, shop,
/// profile). Used by Semantics(identifier:) — maps to iOS
/// UIAccessibilityIdentifier and Android resource-id for Maestro / Patrol.
abstract class ScreensIds {
  // yoyo.nearby (B10)
  static const yoyoNearbyFilter = 'yoyo.nearby.btn_filter';
  static String yoyoNearbyCard(int i) => 'yoyo.nearby.card_user_$i';
  static String yoyoNearbyAvatar(int i) => 'yoyo.nearby.avatar_user_$i';
  static const yoyoWaveSend = 'yoyo.wave.btn_send_wave';
  static const yoyoConnectSubmit = 'yoyo.connect.btn_submit';

  // video.feed (B12)
  static String videoFeedCard(int i) => 'video.feed.card_video_$i';
  static const videoFeedLike = 'video.feed.btn_like';
  static const videoFeedComment = 'video.feed.btn_comment';
  static const videoFeedShare = 'video.feed.btn_share';
  static const videoFeedFollowCreator = 'video.feed.btn_follow_creator';
  static const videoFeedMute = 'video.feed.icon_mute';

  // dating.discover (B11)
  static String datingDiscoverCard(int i) =>
      'dating.discover.card_profile_$i';
  static const datingDiscoverLike = 'dating.discover.btn_like';
  static const datingDiscoverPass = 'dating.discover.btn_pass';

  // social.feed (B12)
  static String socialFeedCard(int i) => 'social.feed.card_post_$i';
  static String socialFeedLike(int i) => 'social.feed.btn_like_post_$i';
  static String socialFeedComment(int i) =>
      'social.feed.btn_comment_post_$i';
  static String socialFeedShare(int i) => 'social.feed.btn_share_post_$i';
  static const socialFeedTabStumble = 'social.feed.tab_stumble';
  static const socialFeedIconFriends = 'social.feed.icon_friends';
  static const socialFeedIconEvents = 'social.feed.icon_events';

  // shop.browse (B11)
  static const shopBrowseSearch = 'shop.browse.input_search';
  static String shopBrowseCategoryChip(String name) =>
      'shop.browse.chip_category_${name.toLowerCase()}';
  static String shopBrowseProduct(int i) => 'shop.browse.card_product_$i';
  static String shopBrowseWishlist(int i) => 'shop.browse.btn_wishlist_$i';

  // profile.my (B13)
  static const profileMyAvatar = 'profile.my.avatar';
  static const profileMyName = 'profile.my.text_name';
  static const profileMyEdit = 'profile.my.btn_edit_profile';
  static const profileMyNotifications = 'profile.my.item_notifications';
  static String profileMyStat(String kind) => 'profile.my.stat_$kind';
}
