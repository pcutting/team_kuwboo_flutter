// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedCreator _$FeedCreatorFromJson(Map<String, dynamic> json) => _FeedCreator(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String?,
  isBot: json['isBot'] as bool? ?? false,
);

Map<String, dynamic> _$FeedCreatorToJson(_FeedCreator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isBot': instance.isBot,
    };

_Content _$ContentFromJson(Map<String, dynamic> json) => _Content(
  id: json['id'] as String?,
  type: $enumDecode(_$ContentTypeEnumMap, json['type']),
  creatorId: _readCreatorId(json, 'creatorId') as String?,
  creator: json['creator'] == null
      ? null
      : FeedCreator.fromJson(json['creator'] as Map<String, dynamic>),
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.public_,
  tier:
      $enumDecodeNullable(_$ContentTierEnumMap, json['tier']) ??
      ContentTier.free,
  status:
      $enumDecodeNullable(_$ContentStatusEnumMap, json['status']) ??
      ContentStatus.active,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  videoUrl: json['videoUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  caption: json['caption'] as String?,
  text: json['text'] as String?,
  subType: $enumDecodeNullable(_$PostSubTypeEnumMap, json['subType']),
  title: json['title'] as String?,
  priceCents: (json['priceCents'] as num?)?.toInt(),
  currency: json['currency'] as String? ?? 'GBP',
  condition: json['condition'] as String?,
);

Map<String, dynamic> _$ContentToJson(_Content instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ContentTypeEnumMap[instance.type]!,
  'creatorId': instance.creatorId,
  'creator': instance.creator,
  'visibility': _$VisibilityEnumMap[instance.visibility]!,
  'tier': _$ContentTierEnumMap[instance.tier]!,
  'status': _$ContentStatusEnumMap[instance.status]!,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'viewCount': instance.viewCount,
  'shareCount': instance.shareCount,
  'saveCount': instance.saveCount,
  'createdAt': instance.createdAt?.toIso8601String(),
  'videoUrl': instance.videoUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'durationSeconds': instance.durationSeconds,
  'caption': instance.caption,
  'text': instance.text,
  'subType': _$PostSubTypeEnumMap[instance.subType],
  'title': instance.title,
  'priceCents': instance.priceCents,
  'currency': instance.currency,
  'condition': instance.condition,
};

const _$ContentTypeEnumMap = {
  ContentType.video: 'VIDEO',
  ContentType.product: 'PRODUCT',
  ContentType.post: 'POST',
  ContentType.event: 'EVENT',
  ContentType.wantedAd: 'WANTED_AD',
};

const _$VisibilityEnumMap = {
  Visibility.public_: 'PUBLIC',
  Visibility.connections: 'CONNECTIONS',
  Visibility.private_: 'PRIVATE',
};

const _$ContentTierEnumMap = {
  ContentTier.free: 'FREE',
  ContentTier.member: 'MEMBER',
  ContentTier.vip: 'VIP',
  ContentTier.boosted: 'BOOSTED',
};

const _$ContentStatusEnumMap = {
  ContentStatus.pending: 'PENDING',
  ContentStatus.active: 'ACTIVE',
  ContentStatus.hidden: 'HIDDEN',
  ContentStatus.flagged: 'FLAGGED',
  ContentStatus.removed: 'REMOVED',
};

const _$PostSubTypeEnumMap = {
  PostSubType.standard: 'STANDARD',
  PostSubType.blog: 'BLOG',
  PostSubType.notice: 'NOTICE',
  PostSubType.missingPerson: 'MISSING_PERSON',
};

_Video _$VideoFromJson(Map<String, dynamic> json) => _Video(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$ContentTypeEnumMap, json['type']) ??
      ContentType.video,
  creatorId: _readCreatorId(json, 'creatorId') as String,
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.public_,
  tier:
      $enumDecodeNullable(_$ContentTierEnumMap, json['tier']) ??
      ContentTier.free,
  status:
      $enumDecodeNullable(_$ContentStatusEnumMap, json['status']) ??
      ContentStatus.active,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
  videoUrl: json['videoUrl'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  caption: json['caption'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$VideoToJson(_Video instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ContentTypeEnumMap[instance.type]!,
  'creatorId': instance.creatorId,
  'visibility': _$VisibilityEnumMap[instance.visibility]!,
  'tier': _$ContentTierEnumMap[instance.tier]!,
  'status': _$ContentStatusEnumMap[instance.status]!,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'viewCount': instance.viewCount,
  'shareCount': instance.shareCount,
  'saveCount': instance.saveCount,
  'videoUrl': instance.videoUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'durationSeconds': instance.durationSeconds,
  'caption': instance.caption,
  'createdAt': instance.createdAt.toIso8601String(),
};

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$ContentTypeEnumMap, json['type']) ??
      ContentType.post,
  creatorId: _readCreatorId(json, 'creatorId') as String,
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.public_,
  tier:
      $enumDecodeNullable(_$ContentTierEnumMap, json['tier']) ??
      ContentTier.free,
  status:
      $enumDecodeNullable(_$ContentStatusEnumMap, json['status']) ??
      ContentStatus.active,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
  text: json['text'] as String,
  subType:
      $enumDecodeNullable(_$PostSubTypeEnumMap, json['subType']) ??
      PostSubType.standard,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ContentTypeEnumMap[instance.type]!,
  'creatorId': instance.creatorId,
  'visibility': _$VisibilityEnumMap[instance.visibility]!,
  'tier': _$ContentTierEnumMap[instance.tier]!,
  'status': _$ContentStatusEnumMap[instance.status]!,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'viewCount': instance.viewCount,
  'shareCount': instance.shareCount,
  'saveCount': instance.saveCount,
  'text': instance.text,
  'subType': _$PostSubTypeEnumMap[instance.subType]!,
  'createdAt': instance.createdAt.toIso8601String(),
};
