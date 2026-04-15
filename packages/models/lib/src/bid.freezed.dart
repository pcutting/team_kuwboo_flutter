// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

 String get id; String get auctionId; String get bidderId; int get amountCents; DateTime get placedAt;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auctionId,bidderId,amountCents,placedAt);

@override
String toString() {
  return 'Bid(id: $id, auctionId: $auctionId, bidderId: $bidderId, amountCents: $amountCents, placedAt: $placedAt)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 String id, String auctionId, String bidderId, int amountCents, DateTime placedAt
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? auctionId = null,Object? bidderId = null,Object? amountCents = null,Object? placedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String auctionId,  String bidderId,  int amountCents,  DateTime placedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amountCents,_that.placedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String auctionId,  String bidderId,  int amountCents,  DateTime placedAt)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amountCents,_that.placedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String auctionId,  String bidderId,  int amountCents,  DateTime placedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amountCents,_that.placedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid implements Bid {
  const _Bid({required this.id, required this.auctionId, required this.bidderId, required this.amountCents, required this.placedAt});
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

@override final  String id;
@override final  String auctionId;
@override final  String bidderId;
@override final  int amountCents;
@override final  DateTime placedAt;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auctionId,bidderId,amountCents,placedAt);

@override
String toString() {
  return 'Bid(id: $id, auctionId: $auctionId, bidderId: $bidderId, amountCents: $amountCents, placedAt: $placedAt)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 String id, String auctionId, String bidderId, int amountCents, DateTime placedAt
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? auctionId = null,Object? bidderId = null,Object? amountCents = null,Object? placedAt = null,}) {
  return _then(_Bid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AuctionWithBids {

 Auction get auction; List<Bid> get bids;
/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionWithBidsCopyWith<AuctionWithBids> get copyWith => _$AuctionWithBidsCopyWithImpl<AuctionWithBids>(this as AuctionWithBids, _$identity);

  /// Serializes this AuctionWithBids to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionWithBids&&(identical(other.auction, auction) || other.auction == auction)&&const DeepCollectionEquality().equals(other.bids, bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auction,const DeepCollectionEquality().hash(bids));

@override
String toString() {
  return 'AuctionWithBids(auction: $auction, bids: $bids)';
}


}

/// @nodoc
abstract mixin class $AuctionWithBidsCopyWith<$Res>  {
  factory $AuctionWithBidsCopyWith(AuctionWithBids value, $Res Function(AuctionWithBids) _then) = _$AuctionWithBidsCopyWithImpl;
@useResult
$Res call({
 Auction auction, List<Bid> bids
});


$AuctionCopyWith<$Res> get auction;

}
/// @nodoc
class _$AuctionWithBidsCopyWithImpl<$Res>
    implements $AuctionWithBidsCopyWith<$Res> {
  _$AuctionWithBidsCopyWithImpl(this._self, this._then);

  final AuctionWithBids _self;
  final $Res Function(AuctionWithBids) _then;

/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? auction = null,Object? bids = null,}) {
  return _then(_self.copyWith(
auction: null == auction ? _self.auction : auction // ignore: cast_nullable_to_non_nullable
as Auction,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,
  ));
}
/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuctionCopyWith<$Res> get auction {
  
  return $AuctionCopyWith<$Res>(_self.auction, (value) {
    return _then(_self.copyWith(auction: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuctionWithBids].
extension AuctionWithBidsPatterns on AuctionWithBids {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionWithBids value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionWithBids() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionWithBids value)  $default,){
final _that = this;
switch (_that) {
case _AuctionWithBids():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionWithBids value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionWithBids() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Auction auction,  List<Bid> bids)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionWithBids() when $default != null:
return $default(_that.auction,_that.bids);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Auction auction,  List<Bid> bids)  $default,) {final _that = this;
switch (_that) {
case _AuctionWithBids():
return $default(_that.auction,_that.bids);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Auction auction,  List<Bid> bids)?  $default,) {final _that = this;
switch (_that) {
case _AuctionWithBids() when $default != null:
return $default(_that.auction,_that.bids);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionWithBids implements AuctionWithBids {
  const _AuctionWithBids({required this.auction, final  List<Bid> bids = const <Bid>[]}): _bids = bids;
  factory _AuctionWithBids.fromJson(Map<String, dynamic> json) => _$AuctionWithBidsFromJson(json);

@override final  Auction auction;
 final  List<Bid> _bids;
@override@JsonKey() List<Bid> get bids {
  if (_bids is EqualUnmodifiableListView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bids);
}


/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionWithBidsCopyWith<_AuctionWithBids> get copyWith => __$AuctionWithBidsCopyWithImpl<_AuctionWithBids>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionWithBidsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionWithBids&&(identical(other.auction, auction) || other.auction == auction)&&const DeepCollectionEquality().equals(other._bids, _bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auction,const DeepCollectionEquality().hash(_bids));

@override
String toString() {
  return 'AuctionWithBids(auction: $auction, bids: $bids)';
}


}

/// @nodoc
abstract mixin class _$AuctionWithBidsCopyWith<$Res> implements $AuctionWithBidsCopyWith<$Res> {
  factory _$AuctionWithBidsCopyWith(_AuctionWithBids value, $Res Function(_AuctionWithBids) _then) = __$AuctionWithBidsCopyWithImpl;
@override @useResult
$Res call({
 Auction auction, List<Bid> bids
});


@override $AuctionCopyWith<$Res> get auction;

}
/// @nodoc
class __$AuctionWithBidsCopyWithImpl<$Res>
    implements _$AuctionWithBidsCopyWith<$Res> {
  __$AuctionWithBidsCopyWithImpl(this._self, this._then);

  final _AuctionWithBids _self;
  final $Res Function(_AuctionWithBids) _then;

/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? auction = null,Object? bids = null,}) {
  return _then(_AuctionWithBids(
auction: null == auction ? _self.auction : auction // ignore: cast_nullable_to_non_nullable
as Auction,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,
  ));
}

/// Create a copy of AuctionWithBids
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuctionCopyWith<$Res> get auction {
  
  return $AuctionCopyWith<$Res>(_self.auction, (value) {
    return _then(_self.copyWith(auction: value));
  });
}
}

// dart format on
