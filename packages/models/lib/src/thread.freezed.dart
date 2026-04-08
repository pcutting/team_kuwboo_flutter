// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Thread {

 String get id; String? get moduleKey; String? get contextId; String? get lastMessageText; String? get lastMessageSenderId; DateTime? get lastMessageAt; DateTime get createdAt;
/// Create a copy of Thread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadCopyWith<Thread> get copyWith => _$ThreadCopyWithImpl<Thread>(this as Thread, _$identity);

  /// Serializes this Thread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Thread&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleKey, moduleKey) || other.moduleKey == moduleKey)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleKey,contextId,lastMessageText,lastMessageSenderId,lastMessageAt,createdAt);

@override
String toString() {
  return 'Thread(id: $id, moduleKey: $moduleKey, contextId: $contextId, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ThreadCopyWith<$Res>  {
  factory $ThreadCopyWith(Thread value, $Res Function(Thread) _then) = _$ThreadCopyWithImpl;
@useResult
$Res call({
 String id, String? moduleKey, String? contextId, String? lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, DateTime createdAt
});




}
/// @nodoc
class _$ThreadCopyWithImpl<$Res>
    implements $ThreadCopyWith<$Res> {
  _$ThreadCopyWithImpl(this._self, this._then);

  final Thread _self;
  final $Res Function(Thread) _then;

/// Create a copy of Thread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? moduleKey = freezed,Object? contextId = freezed,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleKey: freezed == moduleKey ? _self.moduleKey : moduleKey // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Thread].
extension ThreadPatterns on Thread {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Thread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Thread() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Thread value)  $default,){
final _that = this;
switch (_that) {
case _Thread():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Thread value)?  $default,){
final _that = this;
switch (_that) {
case _Thread() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? moduleKey,  String? contextId,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Thread() when $default != null:
return $default(_that.id,_that.moduleKey,_that.contextId,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? moduleKey,  String? contextId,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Thread():
return $default(_that.id,_that.moduleKey,_that.contextId,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? moduleKey,  String? contextId,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Thread() when $default != null:
return $default(_that.id,_that.moduleKey,_that.contextId,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Thread implements Thread {
  const _Thread({required this.id, this.moduleKey, this.contextId, this.lastMessageText, this.lastMessageSenderId, this.lastMessageAt, required this.createdAt});
  factory _Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);

@override final  String id;
@override final  String? moduleKey;
@override final  String? contextId;
@override final  String? lastMessageText;
@override final  String? lastMessageSenderId;
@override final  DateTime? lastMessageAt;
@override final  DateTime createdAt;

/// Create a copy of Thread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadCopyWith<_Thread> get copyWith => __$ThreadCopyWithImpl<_Thread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Thread&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleKey, moduleKey) || other.moduleKey == moduleKey)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleKey,contextId,lastMessageText,lastMessageSenderId,lastMessageAt,createdAt);

@override
String toString() {
  return 'Thread(id: $id, moduleKey: $moduleKey, contextId: $contextId, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ThreadCopyWith<$Res> implements $ThreadCopyWith<$Res> {
  factory _$ThreadCopyWith(_Thread value, $Res Function(_Thread) _then) = __$ThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, String? moduleKey, String? contextId, String? lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, DateTime createdAt
});




}
/// @nodoc
class __$ThreadCopyWithImpl<$Res>
    implements _$ThreadCopyWith<$Res> {
  __$ThreadCopyWithImpl(this._self, this._then);

  final _Thread _self;
  final $Res Function(_Thread) _then;

/// Create a copy of Thread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? moduleKey = freezed,Object? contextId = freezed,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_Thread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleKey: freezed == moduleKey ? _self.moduleKey : moduleKey // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Message {

 String get id; String get threadId; String get senderId; String get text; String? get mediaId; DateTime get createdAt;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,senderId,text,mediaId,createdAt);

@override
String toString() {
  return 'Message(id: $id, threadId: $threadId, senderId: $senderId, text: $text, mediaId: $mediaId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String threadId, String senderId, String text, String? mediaId, DateTime createdAt
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = null,Object? senderId = null,Object? text = null,Object? mediaId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaId: freezed == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String threadId,  String senderId,  String text,  String? mediaId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.threadId,_that.senderId,_that.text,_that.mediaId,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String threadId,  String senderId,  String text,  String? mediaId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.threadId,_that.senderId,_that.text,_that.mediaId,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String threadId,  String senderId,  String text,  String? mediaId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.threadId,_that.senderId,_that.text,_that.mediaId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, required this.threadId, required this.senderId, required this.text, this.mediaId, required this.createdAt});
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override final  String threadId;
@override final  String senderId;
@override final  String text;
@override final  String? mediaId;
@override final  DateTime createdAt;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,senderId,text,mediaId,createdAt);

@override
String toString() {
  return 'Message(id: $id, threadId: $threadId, senderId: $senderId, text: $text, mediaId: $mediaId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String threadId, String senderId, String text, String? mediaId, DateTime createdAt
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = null,Object? senderId = null,Object? text = null,Object? mediaId = freezed,Object? createdAt = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaId: freezed == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
