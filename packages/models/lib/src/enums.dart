import 'package:json_annotation/json_annotation.dart';

/// User roles within the platform.
@JsonEnum(valueField: 'value')
enum Role {
  user('USER'),
  moderator('MODERATOR'),
  admin('ADMIN');

  const Role(this.value);
  final String value;
}

/// Account-level user status.
@JsonEnum(valueField: 'value')
enum UserStatus {
  active('ACTIVE'),
  suspended('SUSPENDED'),
  banned('BANNED'),
  deactivated('DEACTIVATED');

  const UserStatus(this.value);
  final String value;
}

/// Real-time presence indicator.
@JsonEnum(valueField: 'value')
enum OnlineStatus {
  online('ONLINE'),
  away('AWAY'),
  offline('OFFLINE');

  const OnlineStatus(this.value);
  final String value;
}

/// Content type discriminator (STI column).
@JsonEnum(valueField: 'value')
enum ContentType {
  video('VIDEO'),
  product('PRODUCT'),
  post('POST'),
  event('EVENT'),
  wantedAd('WANTED_AD');

  const ContentType(this.value);
  final String value;
}

/// Content moderation / lifecycle status.
@JsonEnum(valueField: 'value')
enum ContentStatus {
  pending('PENDING'),
  active('ACTIVE'),
  hidden('HIDDEN'),
  flagged('FLAGGED'),
  removed('REMOVED');

  const ContentStatus(this.value);
  final String value;
}

/// Access control for content visibility.
@JsonEnum(valueField: 'value')
enum Visibility {
  public_('PUBLIC'),
  connections('CONNECTIONS'),
  private_('PRIVATE');

  const Visibility(this.value);
  final String value;
}

/// Feed ranking tier for content prominence.
@JsonEnum(valueField: 'value')
enum ContentTier {
  free('FREE'),
  member('MEMBER'),
  vip('VIP'),
  boosted('BOOSTED');

  const ContentTier(this.value);
  final String value;
}

/// Sub-type for Post content items.
@JsonEnum(valueField: 'value')
enum PostSubType {
  standard('STANDARD'),
  blog('BLOG'),
  notice('NOTICE'),
  missingPerson('MISSING_PERSON');

  const PostSubType(this.value);
  final String value;
}

/// Connection relationship context.
@JsonEnum(valueField: 'value')
enum ConnectionContext {
  follow('FOLLOW'),
  friend('FRIEND'),
  match('MATCH'),
  yoyo('YOYO');

  const ConnectionContext(this.value);
  final String value;
}

/// Connection request lifecycle status.
@JsonEnum(valueField: 'value')
enum ConnectionStatus {
  pending('PENDING'),
  active('ACTIVE'),
  rejected('REJECTED');

  const ConnectionStatus(this.value);
  final String value;
}

/// Module scope for per-module following and threads.
@JsonEnum(valueField: 'value')
enum ModuleScope {
  video('VIDEO'),
  shop('SHOP'),
  social('SOCIAL'),
  dating('DATING');

  const ModuleScope(this.value);
  final String value;
}

/// Notification event types.
@JsonEnum(valueField: 'value')
enum NotificationType {
  like('LIKE'),
  comment('COMMENT'),
  follow('FOLLOW'),
  match('MATCH'),
  message('MESSAGE'),
  bid('BID'),
  auctionEnding('AUCTION_ENDING'),
  auctionWon('AUCTION_WON'),
  auctionOutbid('AUCTION_OUTBID'),
  mention('MENTION'),
  yoyoNearby('YOYO_NEARBY'),
  system('SYSTEM');

  const NotificationType(this.value);
  final String value;
}

/// Interaction state types (idempotent toggles).
@JsonEnum(valueField: 'value')
enum InteractionStateType {
  like('LIKE'),
  save('SAVE');

  const InteractionStateType(this.value);
  final String value;
}

/// Interaction event types (append-only log).
@JsonEnum(valueField: 'value')
enum InteractionEventType {
  view('VIEW'),
  share('SHARE'),
  bid('BID'),
  swipeRight('SWIPE_RIGHT'),
  swipeLeft('SWIPE_LEFT'),
  superLike('SUPER_LIKE'),
  spark('SPARK');

  const InteractionEventType(this.value);
  final String value;
}
