// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.like: 'LIKE',
  NotificationType.comment: 'COMMENT',
  NotificationType.follow: 'FOLLOW',
  NotificationType.match: 'MATCH',
  NotificationType.message: 'MESSAGE',
  NotificationType.bid: 'BID',
  NotificationType.auctionEnding: 'AUCTION_ENDING',
  NotificationType.auctionWon: 'AUCTION_WON',
  NotificationType.auctionOutbid: 'AUCTION_OUTBID',
  NotificationType.mention: 'MENTION',
  NotificationType.yoyoNearby: 'YOYO_NEARBY',
  NotificationType.system: 'SYSTEM',
};
