// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Auction {

 String get id; String get productId; int get startPriceCents; int get currentPriceCents; int get minIncrementCents; DateTime get startsAt; DateTime get endsAt; String get status; String? get winnerId; DateTime get createdAt;
/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionCopyWith<Auction> get copyWith => _$AuctionCopyWithImpl<Auction>(this as Auction, _$identity);

  /// Serializes this Auction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.startPriceCents, startPriceCents) || other.startPriceCents == startPriceCents)&&(identical(other.currentPriceCents, currentPriceCents) || other.currentPriceCents == currentPriceCents)&&(identical(other.minIncrementCents, minIncrementCents) || other.minIncrementCents == minIncrementCents)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,startPriceCents,currentPriceCents,minIncrementCents,startsAt,endsAt,status,winnerId,createdAt);

@override
String toString() {
  return 'Auction(id: $id, productId: $productId, startPriceCents: $startPriceCents, currentPriceCents: $currentPriceCents, minIncrementCents: $minIncrementCents, startsAt: $startsAt, endsAt: $endsAt, status: $status, winnerId: $winnerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AuctionCopyWith<$Res>  {
  factory $AuctionCopyWith(Auction value, $Res Function(Auction) _then) = _$AuctionCopyWithImpl;
@useResult
$Res call({
 String id, String productId, int startPriceCents, int currentPriceCents, int minIncrementCents, DateTime startsAt, DateTime endsAt, String status, String? winnerId, DateTime createdAt
});




}
/// @nodoc
class _$AuctionCopyWithImpl<$Res>
    implements $AuctionCopyWith<$Res> {
  _$AuctionCopyWithImpl(this._self, this._then);

  final Auction _self;
  final $Res Function(Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? startPriceCents = null,Object? currentPriceCents = null,Object? minIncrementCents = null,Object? startsAt = null,Object? endsAt = null,Object? status = null,Object? winnerId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,startPriceCents: null == startPriceCents ? _self.startPriceCents : startPriceCents // ignore: cast_nullable_to_non_nullable
as int,currentPriceCents: null == currentPriceCents ? _self.currentPriceCents : currentPriceCents // ignore: cast_nullable_to_non_nullable
as int,minIncrementCents: null == minIncrementCents ? _self.minIncrementCents : minIncrementCents // ignore: cast_nullable_to_non_nullable
as int,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Auction].
extension AuctionPatterns on Auction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Auction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Auction value)  $default,){
final _that = this;
switch (_that) {
case _Auction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Auction value)?  $default,){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  int startPriceCents,  int currentPriceCents,  int minIncrementCents,  DateTime startsAt,  DateTime endsAt,  String status,  String? winnerId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.productId,_that.startPriceCents,_that.currentPriceCents,_that.minIncrementCents,_that.startsAt,_that.endsAt,_that.status,_that.winnerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  int startPriceCents,  int currentPriceCents,  int minIncrementCents,  DateTime startsAt,  DateTime endsAt,  String status,  String? winnerId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Auction():
return $default(_that.id,_that.productId,_that.startPriceCents,_that.currentPriceCents,_that.minIncrementCents,_that.startsAt,_that.endsAt,_that.status,_that.winnerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  int startPriceCents,  int currentPriceCents,  int minIncrementCents,  DateTime startsAt,  DateTime endsAt,  String status,  String? winnerId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.productId,_that.startPriceCents,_that.currentPriceCents,_that.minIncrementCents,_that.startsAt,_that.endsAt,_that.status,_that.winnerId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Auction implements Auction {
  const _Auction({required this.id, required this.productId, required this.startPriceCents, required this.currentPriceCents, required this.minIncrementCents, required this.startsAt, required this.endsAt, required this.status, this.winnerId, required this.createdAt});
  factory _Auction.fromJson(Map<String, dynamic> json) => _$AuctionFromJson(json);

@override final  String id;
@override final  String productId;
@override final  int startPriceCents;
@override final  int currentPriceCents;
@override final  int minIncrementCents;
@override final  DateTime startsAt;
@override final  DateTime endsAt;
@override final  String status;
@override final  String? winnerId;
@override final  DateTime createdAt;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionCopyWith<_Auction> get copyWith => __$AuctionCopyWithImpl<_Auction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.startPriceCents, startPriceCents) || other.startPriceCents == startPriceCents)&&(identical(other.currentPriceCents, currentPriceCents) || other.currentPriceCents == currentPriceCents)&&(identical(other.minIncrementCents, minIncrementCents) || other.minIncrementCents == minIncrementCents)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,startPriceCents,currentPriceCents,minIncrementCents,startsAt,endsAt,status,winnerId,createdAt);

@override
String toString() {
  return 'Auction(id: $id, productId: $productId, startPriceCents: $startPriceCents, currentPriceCents: $currentPriceCents, minIncrementCents: $minIncrementCents, startsAt: $startsAt, endsAt: $endsAt, status: $status, winnerId: $winnerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AuctionCopyWith<$Res> implements $AuctionCopyWith<$Res> {
  factory _$AuctionCopyWith(_Auction value, $Res Function(_Auction) _then) = __$AuctionCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, int startPriceCents, int currentPriceCents, int minIncrementCents, DateTime startsAt, DateTime endsAt, String status, String? winnerId, DateTime createdAt
});




}
/// @nodoc
class __$AuctionCopyWithImpl<$Res>
    implements _$AuctionCopyWith<$Res> {
  __$AuctionCopyWithImpl(this._self, this._then);

  final _Auction _self;
  final $Res Function(_Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? startPriceCents = null,Object? currentPriceCents = null,Object? minIncrementCents = null,Object? startsAt = null,Object? endsAt = null,Object? status = null,Object? winnerId = freezed,Object? createdAt = null,}) {
  return _then(_Auction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,startPriceCents: null == startPriceCents ? _self.startPriceCents : startPriceCents // ignore: cast_nullable_to_non_nullable
as int,currentPriceCents: null == currentPriceCents ? _self.currentPriceCents : currentPriceCents // ignore: cast_nullable_to_non_nullable
as int,minIncrementCents: null == minIncrementCents ? _self.minIncrementCents : minIncrementCents // ignore: cast_nullable_to_non_nullable
as int,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
