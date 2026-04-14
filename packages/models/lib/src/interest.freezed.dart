// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Interest {

 String get id; String get slug; String get label; String? get category; int get displayOrder; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterestCopyWith<Interest> get copyWith => _$InterestCopyWithImpl<Interest>(this as Interest, _$identity);

  /// Serializes this Interest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Interest&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.label, label) || other.label == label)&&(identical(other.category, category) || other.category == category)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,label,category,displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Interest(id: $id, slug: $slug, label: $label, category: $category, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InterestCopyWith<$Res>  {
  factory $InterestCopyWith(Interest value, $Res Function(Interest) _then) = _$InterestCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String label, String? category, int displayOrder, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$InterestCopyWithImpl<$Res>
    implements $InterestCopyWith<$Res> {
  _$InterestCopyWithImpl(this._self, this._then);

  final Interest _self;
  final $Res Function(Interest) _then;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? label = null,Object? category = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Interest].
extension InterestPatterns on Interest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Interest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Interest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Interest value)  $default,){
final _that = this;
switch (_that) {
case _Interest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Interest value)?  $default,){
final _that = this;
switch (_that) {
case _Interest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String label,  String? category,  int displayOrder,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Interest() when $default != null:
return $default(_that.id,_that.slug,_that.label,_that.category,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String label,  String? category,  int displayOrder,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Interest():
return $default(_that.id,_that.slug,_that.label,_that.category,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String label,  String? category,  int displayOrder,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Interest() when $default != null:
return $default(_that.id,_that.slug,_that.label,_that.category,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Interest implements Interest {
  const _Interest({required this.id, required this.slug, required this.label, this.category, this.displayOrder = 0, this.isActive = true, required this.createdAt, required this.updatedAt});
  factory _Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String label;
@override final  String? category;
@override@JsonKey() final  int displayOrder;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterestCopyWith<_Interest> get copyWith => __$InterestCopyWithImpl<_Interest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Interest&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.label, label) || other.label == label)&&(identical(other.category, category) || other.category == category)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,label,category,displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Interest(id: $id, slug: $slug, label: $label, category: $category, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InterestCopyWith<$Res> implements $InterestCopyWith<$Res> {
  factory _$InterestCopyWith(_Interest value, $Res Function(_Interest) _then) = __$InterestCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String label, String? category, int displayOrder, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$InterestCopyWithImpl<$Res>
    implements _$InterestCopyWith<$Res> {
  __$InterestCopyWithImpl(this._self, this._then);

  final _Interest _self;
  final $Res Function(_Interest) _then;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? label = null,Object? category = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Interest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserInterest {

 String get id; String get userId; String get interestId; DateTime get selectedAt;
/// Create a copy of UserInterest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInterestCopyWith<UserInterest> get copyWith => _$UserInterestCopyWithImpl<UserInterest>(this as UserInterest, _$identity);

  /// Serializes this UserInterest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInterest&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.selectedAt, selectedAt) || other.selectedAt == selectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,interestId,selectedAt);

@override
String toString() {
  return 'UserInterest(id: $id, userId: $userId, interestId: $interestId, selectedAt: $selectedAt)';
}


}

/// @nodoc
abstract mixin class $UserInterestCopyWith<$Res>  {
  factory $UserInterestCopyWith(UserInterest value, $Res Function(UserInterest) _then) = _$UserInterestCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String interestId, DateTime selectedAt
});




}
/// @nodoc
class _$UserInterestCopyWithImpl<$Res>
    implements $UserInterestCopyWith<$Res> {
  _$UserInterestCopyWithImpl(this._self, this._then);

  final UserInterest _self;
  final $Res Function(UserInterest) _then;

/// Create a copy of UserInterest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? interestId = null,Object? selectedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,selectedAt: null == selectedAt ? _self.selectedAt : selectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserInterest].
extension UserInterestPatterns on UserInterest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInterest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInterest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInterest value)  $default,){
final _that = this;
switch (_that) {
case _UserInterest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInterest value)?  $default,){
final _that = this;
switch (_that) {
case _UserInterest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String interestId,  DateTime selectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInterest() when $default != null:
return $default(_that.id,_that.userId,_that.interestId,_that.selectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String interestId,  DateTime selectedAt)  $default,) {final _that = this;
switch (_that) {
case _UserInterest():
return $default(_that.id,_that.userId,_that.interestId,_that.selectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String interestId,  DateTime selectedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserInterest() when $default != null:
return $default(_that.id,_that.userId,_that.interestId,_that.selectedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserInterest implements UserInterest {
  const _UserInterest({required this.id, required this.userId, required this.interestId, required this.selectedAt});
  factory _UserInterest.fromJson(Map<String, dynamic> json) => _$UserInterestFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String interestId;
@override final  DateTime selectedAt;

/// Create a copy of UserInterest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInterestCopyWith<_UserInterest> get copyWith => __$UserInterestCopyWithImpl<_UserInterest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserInterestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInterest&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.selectedAt, selectedAt) || other.selectedAt == selectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,interestId,selectedAt);

@override
String toString() {
  return 'UserInterest(id: $id, userId: $userId, interestId: $interestId, selectedAt: $selectedAt)';
}


}

/// @nodoc
abstract mixin class _$UserInterestCopyWith<$Res> implements $UserInterestCopyWith<$Res> {
  factory _$UserInterestCopyWith(_UserInterest value, $Res Function(_UserInterest) _then) = __$UserInterestCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String interestId, DateTime selectedAt
});




}
/// @nodoc
class __$UserInterestCopyWithImpl<$Res>
    implements _$UserInterestCopyWith<$Res> {
  __$UserInterestCopyWithImpl(this._self, this._then);

  final _UserInterest _self;
  final $Res Function(_UserInterest) _then;

/// Create a copy of UserInterest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? interestId = null,Object? selectedAt = null,}) {
  return _then(_UserInterest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,selectedAt: null == selectedAt ? _self.selectedAt : selectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$InterestSignal {

 String get id; String get userId; String get interestId; double get weight; int get eventCount; DateTime get lastSeenAt;
/// Create a copy of InterestSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterestSignalCopyWith<InterestSignal> get copyWith => _$InterestSignalCopyWithImpl<InterestSignal>(this as InterestSignal, _$identity);

  /// Serializes this InterestSignal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterestSignal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,interestId,weight,eventCount,lastSeenAt);

@override
String toString() {
  return 'InterestSignal(id: $id, userId: $userId, interestId: $interestId, weight: $weight, eventCount: $eventCount, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $InterestSignalCopyWith<$Res>  {
  factory $InterestSignalCopyWith(InterestSignal value, $Res Function(InterestSignal) _then) = _$InterestSignalCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String interestId, double weight, int eventCount, DateTime lastSeenAt
});




}
/// @nodoc
class _$InterestSignalCopyWithImpl<$Res>
    implements $InterestSignalCopyWith<$Res> {
  _$InterestSignalCopyWithImpl(this._self, this._then);

  final InterestSignal _self;
  final $Res Function(InterestSignal) _then;

/// Create a copy of InterestSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? interestId = null,Object? weight = null,Object? eventCount = null,Object? lastSeenAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InterestSignal].
extension InterestSignalPatterns on InterestSignal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterestSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterestSignal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterestSignal value)  $default,){
final _that = this;
switch (_that) {
case _InterestSignal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterestSignal value)?  $default,){
final _that = this;
switch (_that) {
case _InterestSignal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String interestId,  double weight,  int eventCount,  DateTime lastSeenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterestSignal() when $default != null:
return $default(_that.id,_that.userId,_that.interestId,_that.weight,_that.eventCount,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String interestId,  double weight,  int eventCount,  DateTime lastSeenAt)  $default,) {final _that = this;
switch (_that) {
case _InterestSignal():
return $default(_that.id,_that.userId,_that.interestId,_that.weight,_that.eventCount,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String interestId,  double weight,  int eventCount,  DateTime lastSeenAt)?  $default,) {final _that = this;
switch (_that) {
case _InterestSignal() when $default != null:
return $default(_that.id,_that.userId,_that.interestId,_that.weight,_that.eventCount,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterestSignal implements InterestSignal {
  const _InterestSignal({required this.id, required this.userId, required this.interestId, this.weight = 0.0, this.eventCount = 0, required this.lastSeenAt});
  factory _InterestSignal.fromJson(Map<String, dynamic> json) => _$InterestSignalFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String interestId;
@override@JsonKey() final  double weight;
@override@JsonKey() final  int eventCount;
@override final  DateTime lastSeenAt;

/// Create a copy of InterestSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterestSignalCopyWith<_InterestSignal> get copyWith => __$InterestSignalCopyWithImpl<_InterestSignal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterestSignalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterestSignal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,interestId,weight,eventCount,lastSeenAt);

@override
String toString() {
  return 'InterestSignal(id: $id, userId: $userId, interestId: $interestId, weight: $weight, eventCount: $eventCount, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class _$InterestSignalCopyWith<$Res> implements $InterestSignalCopyWith<$Res> {
  factory _$InterestSignalCopyWith(_InterestSignal value, $Res Function(_InterestSignal) _then) = __$InterestSignalCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String interestId, double weight, int eventCount, DateTime lastSeenAt
});




}
/// @nodoc
class __$InterestSignalCopyWithImpl<$Res>
    implements _$InterestSignalCopyWith<$Res> {
  __$InterestSignalCopyWithImpl(this._self, this._then);

  final _InterestSignal _self;
  final $Res Function(_InterestSignal) _then;

/// Create a copy of InterestSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? interestId = null,Object? weight = null,Object? eventCount = null,Object? lastSeenAt = null,}) {
  return _then(_InterestSignal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
