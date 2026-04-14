// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Credential {

 String get id; String get userId; CredentialType get type; String get identifier; Map<String, dynamic>? get providerData; DateTime get verifiedAt; bool get isPrimary; DateTime? get revokedAt; DateTime get createdAt; DateTime? get lastUsedAt;
/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialCopyWith<Credential> get copyWith => _$CredentialCopyWithImpl<Credential>(this as Credential, _$identity);

  /// Serializes this Credential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credential&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&const DeepCollectionEquality().equals(other.providerData, providerData)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,identifier,const DeepCollectionEquality().hash(providerData),verifiedAt,isPrimary,revokedAt,createdAt,lastUsedAt);

@override
String toString() {
  return 'Credential(id: $id, userId: $userId, type: $type, identifier: $identifier, providerData: $providerData, verifiedAt: $verifiedAt, isPrimary: $isPrimary, revokedAt: $revokedAt, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $CredentialCopyWith<$Res>  {
  factory $CredentialCopyWith(Credential value, $Res Function(Credential) _then) = _$CredentialCopyWithImpl;
@useResult
$Res call({
 String id, String userId, CredentialType type, String identifier, Map<String, dynamic>? providerData, DateTime verifiedAt, bool isPrimary, DateTime? revokedAt, DateTime createdAt, DateTime? lastUsedAt
});




}
/// @nodoc
class _$CredentialCopyWithImpl<$Res>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._self, this._then);

  final Credential _self;
  final $Res Function(Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? identifier = null,Object? providerData = freezed,Object? verifiedAt = null,Object? isPrimary = null,Object? revokedAt = freezed,Object? createdAt = null,Object? lastUsedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CredentialType,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,providerData: freezed == providerData ? _self.providerData : providerData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,verifiedAt: null == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Credential].
extension CredentialPatterns on Credential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Credential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Credential value)  $default,){
final _that = this;
switch (_that) {
case _Credential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Credential value)?  $default,){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  CredentialType type,  String identifier,  Map<String, dynamic>? providerData,  DateTime verifiedAt,  bool isPrimary,  DateTime? revokedAt,  DateTime createdAt,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.identifier,_that.providerData,_that.verifiedAt,_that.isPrimary,_that.revokedAt,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  CredentialType type,  String identifier,  Map<String, dynamic>? providerData,  DateTime verifiedAt,  bool isPrimary,  DateTime? revokedAt,  DateTime createdAt,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _Credential():
return $default(_that.id,_that.userId,_that.type,_that.identifier,_that.providerData,_that.verifiedAt,_that.isPrimary,_that.revokedAt,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  CredentialType type,  String identifier,  Map<String, dynamic>? providerData,  DateTime verifiedAt,  bool isPrimary,  DateTime? revokedAt,  DateTime createdAt,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.identifier,_that.providerData,_that.verifiedAt,_that.isPrimary,_that.revokedAt,_that.createdAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Credential implements Credential {
  const _Credential({required this.id, required this.userId, required this.type, required this.identifier, final  Map<String, dynamic>? providerData, required this.verifiedAt, this.isPrimary = false, this.revokedAt, required this.createdAt, this.lastUsedAt}): _providerData = providerData;
  factory _Credential.fromJson(Map<String, dynamic> json) => _$CredentialFromJson(json);

@override final  String id;
@override final  String userId;
@override final  CredentialType type;
@override final  String identifier;
 final  Map<String, dynamic>? _providerData;
@override Map<String, dynamic>? get providerData {
  final value = _providerData;
  if (value == null) return null;
  if (_providerData is EqualUnmodifiableMapView) return _providerData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime verifiedAt;
@override@JsonKey() final  bool isPrimary;
@override final  DateTime? revokedAt;
@override final  DateTime createdAt;
@override final  DateTime? lastUsedAt;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialCopyWith<_Credential> get copyWith => __$CredentialCopyWithImpl<_Credential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Credential&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&const DeepCollectionEquality().equals(other._providerData, _providerData)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,identifier,const DeepCollectionEquality().hash(_providerData),verifiedAt,isPrimary,revokedAt,createdAt,lastUsedAt);

@override
String toString() {
  return 'Credential(id: $id, userId: $userId, type: $type, identifier: $identifier, providerData: $providerData, verifiedAt: $verifiedAt, isPrimary: $isPrimary, revokedAt: $revokedAt, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$CredentialCopyWith<$Res> implements $CredentialCopyWith<$Res> {
  factory _$CredentialCopyWith(_Credential value, $Res Function(_Credential) _then) = __$CredentialCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, CredentialType type, String identifier, Map<String, dynamic>? providerData, DateTime verifiedAt, bool isPrimary, DateTime? revokedAt, DateTime createdAt, DateTime? lastUsedAt
});




}
/// @nodoc
class __$CredentialCopyWithImpl<$Res>
    implements _$CredentialCopyWith<$Res> {
  __$CredentialCopyWithImpl(this._self, this._then);

  final _Credential _self;
  final $Res Function(_Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? identifier = null,Object? providerData = freezed,Object? verifiedAt = null,Object? isPrimary = null,Object? revokedAt = freezed,Object? createdAt = null,Object? lastUsedAt = freezed,}) {
  return _then(_Credential(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CredentialType,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,providerData: freezed == providerData ? _self._providerData : providerData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,verifiedAt: null == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
