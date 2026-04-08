// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yoyo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NearbyUser {

 String get id; String get name; String? get avatarUrl; double get distanceKm; String? get onlineStatus;
/// Create a copy of NearbyUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearbyUserCopyWith<NearbyUser> get copyWith => _$NearbyUserCopyWithImpl<NearbyUser>(this as NearbyUser, _$identity);

  /// Serializes this NearbyUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NearbyUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,distanceKm,onlineStatus);

@override
String toString() {
  return 'NearbyUser(id: $id, name: $name, avatarUrl: $avatarUrl, distanceKm: $distanceKm, onlineStatus: $onlineStatus)';
}


}

/// @nodoc
abstract mixin class $NearbyUserCopyWith<$Res>  {
  factory $NearbyUserCopyWith(NearbyUser value, $Res Function(NearbyUser) _then) = _$NearbyUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatarUrl, double distanceKm, String? onlineStatus
});




}
/// @nodoc
class _$NearbyUserCopyWithImpl<$Res>
    implements $NearbyUserCopyWith<$Res> {
  _$NearbyUserCopyWithImpl(this._self, this._then);

  final NearbyUser _self;
  final $Res Function(NearbyUser) _then;

/// Create a copy of NearbyUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? distanceKm = null,Object? onlineStatus = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,onlineStatus: freezed == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NearbyUser].
extension NearbyUserPatterns on NearbyUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NearbyUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NearbyUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NearbyUser value)  $default,){
final _that = this;
switch (_that) {
case _NearbyUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NearbyUser value)?  $default,){
final _that = this;
switch (_that) {
case _NearbyUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  double distanceKm,  String? onlineStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NearbyUser() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.distanceKm,_that.onlineStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  double distanceKm,  String? onlineStatus)  $default,) {final _that = this;
switch (_that) {
case _NearbyUser():
return $default(_that.id,_that.name,_that.avatarUrl,_that.distanceKm,_that.onlineStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatarUrl,  double distanceKm,  String? onlineStatus)?  $default,) {final _that = this;
switch (_that) {
case _NearbyUser() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.distanceKm,_that.onlineStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NearbyUser implements NearbyUser {
  const _NearbyUser({required this.id, required this.name, this.avatarUrl, required this.distanceKm, this.onlineStatus});
  factory _NearbyUser.fromJson(Map<String, dynamic> json) => _$NearbyUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? avatarUrl;
@override final  double distanceKm;
@override final  String? onlineStatus;

/// Create a copy of NearbyUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NearbyUserCopyWith<_NearbyUser> get copyWith => __$NearbyUserCopyWithImpl<_NearbyUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NearbyUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NearbyUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,distanceKm,onlineStatus);

@override
String toString() {
  return 'NearbyUser(id: $id, name: $name, avatarUrl: $avatarUrl, distanceKm: $distanceKm, onlineStatus: $onlineStatus)';
}


}

/// @nodoc
abstract mixin class _$NearbyUserCopyWith<$Res> implements $NearbyUserCopyWith<$Res> {
  factory _$NearbyUserCopyWith(_NearbyUser value, $Res Function(_NearbyUser) _then) = __$NearbyUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatarUrl, double distanceKm, String? onlineStatus
});




}
/// @nodoc
class __$NearbyUserCopyWithImpl<$Res>
    implements _$NearbyUserCopyWith<$Res> {
  __$NearbyUserCopyWithImpl(this._self, this._then);

  final _NearbyUser _self;
  final $Res Function(_NearbyUser) _then;

/// Create a copy of NearbyUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? distanceKm = null,Object? onlineStatus = freezed,}) {
  return _then(_NearbyUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,onlineStatus: freezed == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$YoyoSettings {

 bool get isVisible; int get radiusKm; int? get ageMin; int? get ageMax; String? get genderFilter;
/// Create a copy of YoyoSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$YoyoSettingsCopyWith<YoyoSettings> get copyWith => _$YoyoSettingsCopyWithImpl<YoyoSettings>(this as YoyoSettings, _$identity);

  /// Serializes this YoyoSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is YoyoSettings&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.genderFilter, genderFilter) || other.genderFilter == genderFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,radiusKm,ageMin,ageMax,genderFilter);

@override
String toString() {
  return 'YoyoSettings(isVisible: $isVisible, radiusKm: $radiusKm, ageMin: $ageMin, ageMax: $ageMax, genderFilter: $genderFilter)';
}


}

/// @nodoc
abstract mixin class $YoyoSettingsCopyWith<$Res>  {
  factory $YoyoSettingsCopyWith(YoyoSettings value, $Res Function(YoyoSettings) _then) = _$YoyoSettingsCopyWithImpl;
@useResult
$Res call({
 bool isVisible, int radiusKm, int? ageMin, int? ageMax, String? genderFilter
});




}
/// @nodoc
class _$YoyoSettingsCopyWithImpl<$Res>
    implements $YoyoSettingsCopyWith<$Res> {
  _$YoyoSettingsCopyWithImpl(this._self, this._then);

  final YoyoSettings _self;
  final $Res Function(YoyoSettings) _then;

/// Create a copy of YoyoSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isVisible = null,Object? radiusKm = null,Object? ageMin = freezed,Object? ageMax = freezed,Object? genderFilter = freezed,}) {
  return _then(_self.copyWith(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as int,ageMin: freezed == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int?,ageMax: freezed == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int?,genderFilter: freezed == genderFilter ? _self.genderFilter : genderFilter // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [YoyoSettings].
extension YoyoSettingsPatterns on YoyoSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _YoyoSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _YoyoSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _YoyoSettings value)  $default,){
final _that = this;
switch (_that) {
case _YoyoSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _YoyoSettings value)?  $default,){
final _that = this;
switch (_that) {
case _YoyoSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isVisible,  int radiusKm,  int? ageMin,  int? ageMax,  String? genderFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _YoyoSettings() when $default != null:
return $default(_that.isVisible,_that.radiusKm,_that.ageMin,_that.ageMax,_that.genderFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isVisible,  int radiusKm,  int? ageMin,  int? ageMax,  String? genderFilter)  $default,) {final _that = this;
switch (_that) {
case _YoyoSettings():
return $default(_that.isVisible,_that.radiusKm,_that.ageMin,_that.ageMax,_that.genderFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isVisible,  int radiusKm,  int? ageMin,  int? ageMax,  String? genderFilter)?  $default,) {final _that = this;
switch (_that) {
case _YoyoSettings() when $default != null:
return $default(_that.isVisible,_that.radiusKm,_that.ageMin,_that.ageMax,_that.genderFilter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _YoyoSettings implements YoyoSettings {
  const _YoyoSettings({this.isVisible = true, this.radiusKm = 10, this.ageMin, this.ageMax, this.genderFilter});
  factory _YoyoSettings.fromJson(Map<String, dynamic> json) => _$YoyoSettingsFromJson(json);

@override@JsonKey() final  bool isVisible;
@override@JsonKey() final  int radiusKm;
@override final  int? ageMin;
@override final  int? ageMax;
@override final  String? genderFilter;

/// Create a copy of YoyoSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$YoyoSettingsCopyWith<_YoyoSettings> get copyWith => __$YoyoSettingsCopyWithImpl<_YoyoSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$YoyoSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _YoyoSettings&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.genderFilter, genderFilter) || other.genderFilter == genderFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,radiusKm,ageMin,ageMax,genderFilter);

@override
String toString() {
  return 'YoyoSettings(isVisible: $isVisible, radiusKm: $radiusKm, ageMin: $ageMin, ageMax: $ageMax, genderFilter: $genderFilter)';
}


}

/// @nodoc
abstract mixin class _$YoyoSettingsCopyWith<$Res> implements $YoyoSettingsCopyWith<$Res> {
  factory _$YoyoSettingsCopyWith(_YoyoSettings value, $Res Function(_YoyoSettings) _then) = __$YoyoSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool isVisible, int radiusKm, int? ageMin, int? ageMax, String? genderFilter
});




}
/// @nodoc
class __$YoyoSettingsCopyWithImpl<$Res>
    implements _$YoyoSettingsCopyWith<$Res> {
  __$YoyoSettingsCopyWithImpl(this._self, this._then);

  final _YoyoSettings _self;
  final $Res Function(_YoyoSettings) _then;

/// Create a copy of YoyoSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isVisible = null,Object? radiusKm = null,Object? ageMin = freezed,Object? ageMax = freezed,Object? genderFilter = freezed,}) {
  return _then(_YoyoSettings(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as int,ageMin: freezed == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int?,ageMax: freezed == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int?,genderFilter: freezed == genderFilter ? _self.genderFilter : genderFilter // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Wave {

 String get id; String get fromUserId; String get toUserId; String? get fromUserName; String? get fromUserAvatar; String? get message; String get status; DateTime get createdAt;
/// Create a copy of Wave
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaveCopyWith<Wave> get copyWith => _$WaveCopyWithImpl<Wave>(this as Wave, _$identity);

  /// Serializes this Wave to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wave&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.fromUserName, fromUserName) || other.fromUserName == fromUserName)&&(identical(other.fromUserAvatar, fromUserAvatar) || other.fromUserAvatar == fromUserAvatar)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,fromUserName,fromUserAvatar,message,status,createdAt);

@override
String toString() {
  return 'Wave(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, fromUserName: $fromUserName, fromUserAvatar: $fromUserAvatar, message: $message, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WaveCopyWith<$Res>  {
  factory $WaveCopyWith(Wave value, $Res Function(Wave) _then) = _$WaveCopyWithImpl;
@useResult
$Res call({
 String id, String fromUserId, String toUserId, String? fromUserName, String? fromUserAvatar, String? message, String status, DateTime createdAt
});




}
/// @nodoc
class _$WaveCopyWithImpl<$Res>
    implements $WaveCopyWith<$Res> {
  _$WaveCopyWithImpl(this._self, this._then);

  final Wave _self;
  final $Res Function(Wave) _then;

/// Create a copy of Wave
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? fromUserName = freezed,Object? fromUserAvatar = freezed,Object? message = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,fromUserName: freezed == fromUserName ? _self.fromUserName : fromUserName // ignore: cast_nullable_to_non_nullable
as String?,fromUserAvatar: freezed == fromUserAvatar ? _self.fromUserAvatar : fromUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Wave].
extension WavePatterns on Wave {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wave value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wave() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wave value)  $default,){
final _that = this;
switch (_that) {
case _Wave():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wave value)?  $default,){
final _that = this;
switch (_that) {
case _Wave() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  String? fromUserName,  String? fromUserAvatar,  String? message,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wave() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUserName,_that.fromUserAvatar,_that.message,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  String? fromUserName,  String? fromUserAvatar,  String? message,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Wave():
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUserName,_that.fromUserAvatar,_that.message,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromUserId,  String toUserId,  String? fromUserName,  String? fromUserAvatar,  String? message,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Wave() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUserName,_that.fromUserAvatar,_that.message,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wave implements Wave {
  const _Wave({required this.id, required this.fromUserId, required this.toUserId, this.fromUserName, this.fromUserAvatar, this.message, required this.status, required this.createdAt});
  factory _Wave.fromJson(Map<String, dynamic> json) => _$WaveFromJson(json);

@override final  String id;
@override final  String fromUserId;
@override final  String toUserId;
@override final  String? fromUserName;
@override final  String? fromUserAvatar;
@override final  String? message;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of Wave
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaveCopyWith<_Wave> get copyWith => __$WaveCopyWithImpl<_Wave>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wave&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.fromUserName, fromUserName) || other.fromUserName == fromUserName)&&(identical(other.fromUserAvatar, fromUserAvatar) || other.fromUserAvatar == fromUserAvatar)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,fromUserName,fromUserAvatar,message,status,createdAt);

@override
String toString() {
  return 'Wave(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, fromUserName: $fromUserName, fromUserAvatar: $fromUserAvatar, message: $message, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WaveCopyWith<$Res> implements $WaveCopyWith<$Res> {
  factory _$WaveCopyWith(_Wave value, $Res Function(_Wave) _then) = __$WaveCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromUserId, String toUserId, String? fromUserName, String? fromUserAvatar, String? message, String status, DateTime createdAt
});




}
/// @nodoc
class __$WaveCopyWithImpl<$Res>
    implements _$WaveCopyWith<$Res> {
  __$WaveCopyWithImpl(this._self, this._then);

  final _Wave _self;
  final $Res Function(_Wave) _then;

/// Create a copy of Wave
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? fromUserName = freezed,Object? fromUserAvatar = freezed,Object? message = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_Wave(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,fromUserName: freezed == fromUserName ? _self.fromUserName : fromUserName // ignore: cast_nullable_to_non_nullable
as String?,fromUserAvatar: freezed == fromUserAvatar ? _self.fromUserAvatar : fromUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
