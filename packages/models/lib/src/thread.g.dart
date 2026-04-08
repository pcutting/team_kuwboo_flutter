// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Thread _$ThreadFromJson(Map<String, dynamic> json) => _Thread(
  id: json['id'] as String,
  moduleKey: json['moduleKey'] as String?,
  contextId: json['contextId'] as String?,
  lastMessageText: json['lastMessageText'] as String?,
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ThreadToJson(_Thread instance) => <String, dynamic>{
  'id': instance.id,
  'moduleKey': instance.moduleKey,
  'contextId': instance.contextId,
  'lastMessageText': instance.lastMessageText,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  threadId: json['threadId'] as String,
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  mediaId: json['mediaId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'threadId': instance.threadId,
  'senderId': instance.senderId,
  'text': instance.text,
  'mediaId': instance.mediaId,
  'createdAt': instance.createdAt.toIso8601String(),
};
