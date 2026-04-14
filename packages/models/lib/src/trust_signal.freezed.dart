// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trust_signal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrustSignal {

 String get id; String get userId; String get signalType; int get delta; String? get source; String? get reason; Map<String, dynamic>? get metadata; DateTime? get expiresAt; DateTime get createdAt;
/// Create a copy of TrustSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustSignalCopyWith<TrustSignal> get copyWith => _$TrustSignalCopyWithImpl<TrustSignal>(this as TrustSignal, _$identity);

  /// Serializes this TrustSignal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustSignal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.signalType, signalType) || other.signalType == signalType)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.source, source) || other.source == source)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,signalType,delta,source,reason,const DeepCollectionEquality().hash(metadata),expiresAt,createdAt);

@override
String toString() {
  return 'TrustSignal(id: $id, userId: $userId, signalType: $signalType, delta: $delta, source: $source, reason: $reason, metadata: $metadata, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrustSignalCopyWith<$Res>  {
  factory $TrustSignalCopyWith(TrustSignal value, $Res Function(TrustSignal) _then) = _$TrustSignalCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String signalType, int delta, String? source, String? reason, Map<String, dynamic>? metadata, DateTime? expiresAt, DateTime createdAt
});




}
/// @nodoc
class _$TrustSignalCopyWithImpl<$Res>
    implements $TrustSignalCopyWith<$Res> {
  _$TrustSignalCopyWithImpl(this._self, this._then);

  final TrustSignal _self;
  final $Res Function(TrustSignal) _then;

/// Create a copy of TrustSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? signalType = null,Object? delta = null,Object? source = freezed,Object? reason = freezed,Object? metadata = freezed,Object? expiresAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,signalType: null == signalType ? _self.signalType : signalType // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustSignal].
extension TrustSignalPatterns on TrustSignal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustSignal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustSignal value)  $default,){
final _that = this;
switch (_that) {
case _TrustSignal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustSignal value)?  $default,){
final _that = this;
switch (_that) {
case _TrustSignal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String signalType,  int delta,  String? source,  String? reason,  Map<String, dynamic>? metadata,  DateTime? expiresAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustSignal() when $default != null:
return $default(_that.id,_that.userId,_that.signalType,_that.delta,_that.source,_that.reason,_that.metadata,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String signalType,  int delta,  String? source,  String? reason,  Map<String, dynamic>? metadata,  DateTime? expiresAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrustSignal():
return $default(_that.id,_that.userId,_that.signalType,_that.delta,_that.source,_that.reason,_that.metadata,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String signalType,  int delta,  String? source,  String? reason,  Map<String, dynamic>? metadata,  DateTime? expiresAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrustSignal() when $default != null:
return $default(_that.id,_that.userId,_that.signalType,_that.delta,_that.source,_that.reason,_that.metadata,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustSignal implements TrustSignal {
  const _TrustSignal({required this.id, required this.userId, required this.signalType, required this.delta, this.source, this.reason, final  Map<String, dynamic>? metadata, this.expiresAt, required this.createdAt}): _metadata = metadata;
  factory _TrustSignal.fromJson(Map<String, dynamic> json) => _$TrustSignalFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String signalType;
@override final  int delta;
@override final  String? source;
@override final  String? reason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? expiresAt;
@override final  DateTime createdAt;

/// Create a copy of TrustSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustSignalCopyWith<_TrustSignal> get copyWith => __$TrustSignalCopyWithImpl<_TrustSignal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustSignalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustSignal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.signalType, signalType) || other.signalType == signalType)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.source, source) || other.source == source)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,signalType,delta,source,reason,const DeepCollectionEquality().hash(_metadata),expiresAt,createdAt);

@override
String toString() {
  return 'TrustSignal(id: $id, userId: $userId, signalType: $signalType, delta: $delta, source: $source, reason: $reason, metadata: $metadata, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrustSignalCopyWith<$Res> implements $TrustSignalCopyWith<$Res> {
  factory _$TrustSignalCopyWith(_TrustSignal value, $Res Function(_TrustSignal) _then) = __$TrustSignalCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String signalType, int delta, String? source, String? reason, Map<String, dynamic>? metadata, DateTime? expiresAt, DateTime createdAt
});




}
/// @nodoc
class __$TrustSignalCopyWithImpl<$Res>
    implements _$TrustSignalCopyWith<$Res> {
  __$TrustSignalCopyWithImpl(this._self, this._then);

  final _TrustSignal _self;
  final $Res Function(_TrustSignal) _then;

/// Create a copy of TrustSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? signalType = null,Object? delta = null,Object? source = freezed,Object? reason = freezed,Object? metadata = freezed,Object? expiresAt = freezed,Object? createdAt = null,}) {
  return _then(_TrustSignal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,signalType: null == signalType ? _self.signalType : signalType // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
