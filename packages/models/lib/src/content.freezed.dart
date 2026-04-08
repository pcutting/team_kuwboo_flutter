// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Content {

 String get id; ContentType get type; String get creatorId; Visibility get visibility; ContentTier get tier; ContentStatus get status; int get likeCount; int get commentCount; int get viewCount; int get shareCount; int get saveCount; DateTime get createdAt;
/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentCopyWith<Content> get copyWith => _$ContentCopyWithImpl<Content>(this as Content, _$identity);

  /// Serializes this Content to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Content&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,createdAt);

@override
String toString() {
  return 'Content(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ContentCopyWith<$Res>  {
  factory $ContentCopyWith(Content value, $Res Function(Content) _then) = _$ContentCopyWithImpl;
@useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, DateTime createdAt
});




}
/// @nodoc
class _$ContentCopyWithImpl<$Res>
    implements $ContentCopyWith<$Res> {
  _$ContentCopyWithImpl(this._self, this._then);

  final Content _self;
  final $Res Function(Content) _then;

/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Content].
extension ContentPatterns on Content {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Content value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Content() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Content value)  $default,){
final _that = this;
switch (_that) {
case _Content():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Content value)?  $default,){
final _that = this;
switch (_that) {
case _Content() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Content() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Content():
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Content() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Content implements Content {
  const _Content({required this.id, required this.type, required this.creatorId, this.visibility = Visibility.public_, this.tier = ContentTier.free, this.status = ContentStatus.active, this.likeCount = 0, this.commentCount = 0, this.viewCount = 0, this.shareCount = 0, this.saveCount = 0, required this.createdAt});
  factory _Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

@override final  String id;
@override final  ContentType type;
@override final  String creatorId;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  ContentTier tier;
@override@JsonKey() final  ContentStatus status;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override@JsonKey() final  int viewCount;
@override@JsonKey() final  int shareCount;
@override@JsonKey() final  int saveCount;
@override final  DateTime createdAt;

/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentCopyWith<_Content> get copyWith => __$ContentCopyWithImpl<_Content>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Content&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,createdAt);

@override
String toString() {
  return 'Content(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ContentCopyWith<$Res> implements $ContentCopyWith<$Res> {
  factory _$ContentCopyWith(_Content value, $Res Function(_Content) _then) = __$ContentCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, DateTime createdAt
});




}
/// @nodoc
class __$ContentCopyWithImpl<$Res>
    implements _$ContentCopyWith<$Res> {
  __$ContentCopyWithImpl(this._self, this._then);

  final _Content _self;
  final $Res Function(_Content) _then;

/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? createdAt = null,}) {
  return _then(_Content(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Video {

 String get id; ContentType get type; String get creatorId; Visibility get visibility; ContentTier get tier; ContentStatus get status; int get likeCount; int get commentCount; int get viewCount; int get shareCount; int get saveCount; String get videoUrl; String? get thumbnailUrl; int get durationSeconds; String? get caption; DateTime get createdAt;
/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCopyWith<Video> get copyWith => _$VideoCopyWithImpl<Video>(this as Video, _$identity);

  /// Serializes this Video to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Video&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,videoUrl,thumbnailUrl,durationSeconds,caption,createdAt);

@override
String toString() {
  return 'Video(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds, caption: $caption, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VideoCopyWith<$Res>  {
  factory $VideoCopyWith(Video value, $Res Function(Video) _then) = _$VideoCopyWithImpl;
@useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, String videoUrl, String? thumbnailUrl, int durationSeconds, String? caption, DateTime createdAt
});




}
/// @nodoc
class _$VideoCopyWithImpl<$Res>
    implements $VideoCopyWith<$Res> {
  _$VideoCopyWithImpl(this._self, this._then);

  final Video _self;
  final $Res Function(Video) _then;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? videoUrl = null,Object? thumbnailUrl = freezed,Object? durationSeconds = null,Object? caption = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Video].
extension VideoPatterns on Video {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Video value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Video() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Video value)  $default,){
final _that = this;
switch (_that) {
case _Video():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Video value)?  $default,){
final _that = this;
switch (_that) {
case _Video() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String videoUrl,  String? thumbnailUrl,  int durationSeconds,  String? caption,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.videoUrl,_that.thumbnailUrl,_that.durationSeconds,_that.caption,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String videoUrl,  String? thumbnailUrl,  int durationSeconds,  String? caption,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Video():
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.videoUrl,_that.thumbnailUrl,_that.durationSeconds,_that.caption,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String videoUrl,  String? thumbnailUrl,  int durationSeconds,  String? caption,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.videoUrl,_that.thumbnailUrl,_that.durationSeconds,_that.caption,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Video implements Video {
  const _Video({required this.id, this.type = ContentType.video, required this.creatorId, this.visibility = Visibility.public_, this.tier = ContentTier.free, this.status = ContentStatus.active, this.likeCount = 0, this.commentCount = 0, this.viewCount = 0, this.shareCount = 0, this.saveCount = 0, required this.videoUrl, this.thumbnailUrl, required this.durationSeconds, this.caption, required this.createdAt});
  factory _Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

@override final  String id;
@override@JsonKey() final  ContentType type;
@override final  String creatorId;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  ContentTier tier;
@override@JsonKey() final  ContentStatus status;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override@JsonKey() final  int viewCount;
@override@JsonKey() final  int shareCount;
@override@JsonKey() final  int saveCount;
@override final  String videoUrl;
@override final  String? thumbnailUrl;
@override final  int durationSeconds;
@override final  String? caption;
@override final  DateTime createdAt;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCopyWith<_Video> get copyWith => __$VideoCopyWithImpl<_Video>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Video&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,videoUrl,thumbnailUrl,durationSeconds,caption,createdAt);

@override
String toString() {
  return 'Video(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds, caption: $caption, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VideoCopyWith<$Res> implements $VideoCopyWith<$Res> {
  factory _$VideoCopyWith(_Video value, $Res Function(_Video) _then) = __$VideoCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, String videoUrl, String? thumbnailUrl, int durationSeconds, String? caption, DateTime createdAt
});




}
/// @nodoc
class __$VideoCopyWithImpl<$Res>
    implements _$VideoCopyWith<$Res> {
  __$VideoCopyWithImpl(this._self, this._then);

  final _Video _self;
  final $Res Function(_Video) _then;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? videoUrl = null,Object? thumbnailUrl = freezed,Object? durationSeconds = null,Object? caption = freezed,Object? createdAt = null,}) {
  return _then(_Video(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Post {

 String get id; ContentType get type; String get creatorId; Visibility get visibility; ContentTier get tier; ContentStatus get status; int get likeCount; int get commentCount; int get viewCount; int get shareCount; int get saveCount; String get text; PostSubType get subType; DateTime get createdAt;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.text, text) || other.text == text)&&(identical(other.subType, subType) || other.subType == subType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,text,subType,createdAt);

@override
String toString() {
  return 'Post(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, text: $text, subType: $subType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, String text, PostSubType subType, DateTime createdAt
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? text = null,Object? subType = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,subType: null == subType ? _self.subType : subType // ignore: cast_nullable_to_non_nullable
as PostSubType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String text,  PostSubType subType,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.text,_that.subType,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String text,  PostSubType subType,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.text,_that.subType,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentType type,  String creatorId,  Visibility visibility,  ContentTier tier,  ContentStatus status,  int likeCount,  int commentCount,  int viewCount,  int shareCount,  int saveCount,  String text,  PostSubType subType,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.type,_that.creatorId,_that.visibility,_that.tier,_that.status,_that.likeCount,_that.commentCount,_that.viewCount,_that.shareCount,_that.saveCount,_that.text,_that.subType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, this.type = ContentType.post, required this.creatorId, this.visibility = Visibility.public_, this.tier = ContentTier.free, this.status = ContentStatus.active, this.likeCount = 0, this.commentCount = 0, this.viewCount = 0, this.shareCount = 0, this.saveCount = 0, required this.text, this.subType = PostSubType.standard, required this.createdAt});
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override@JsonKey() final  ContentType type;
@override final  String creatorId;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  ContentTier tier;
@override@JsonKey() final  ContentStatus status;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override@JsonKey() final  int viewCount;
@override@JsonKey() final  int shareCount;
@override@JsonKey() final  int saveCount;
@override final  String text;
@override@JsonKey() final  PostSubType subType;
@override final  DateTime createdAt;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.text, text) || other.text == text)&&(identical(other.subType, subType) || other.subType == subType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,creatorId,visibility,tier,status,likeCount,commentCount,viewCount,shareCount,saveCount,text,subType,createdAt);

@override
String toString() {
  return 'Post(id: $id, type: $type, creatorId: $creatorId, visibility: $visibility, tier: $tier, status: $status, likeCount: $likeCount, commentCount: $commentCount, viewCount: $viewCount, shareCount: $shareCount, saveCount: $saveCount, text: $text, subType: $subType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentType type, String creatorId, Visibility visibility, ContentTier tier, ContentStatus status, int likeCount, int commentCount, int viewCount, int shareCount, int saveCount, String text, PostSubType subType, DateTime createdAt
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? creatorId = null,Object? visibility = null,Object? tier = null,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? viewCount = null,Object? shareCount = null,Object? saveCount = null,Object? text = null,Object? subType = null,Object? createdAt = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentType,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ContentTier,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,subType: null == subType ? _self.subType : subType // ignore: cast_nullable_to_non_nullable
as PostSubType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
