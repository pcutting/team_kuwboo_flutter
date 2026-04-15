// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_rating.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerRating {

 String get id; String get buyerId; String get sellerId; String get productId; int get rating; String? get review; DateTime get createdAt;
/// Create a copy of SellerRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerRatingCopyWith<SellerRating> get copyWith => _$SellerRatingCopyWithImpl<SellerRating>(this as SellerRating, _$identity);

  /// Serializes this SellerRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerRating&&(identical(other.id, id) || other.id == id)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,buyerId,sellerId,productId,rating,review,createdAt);

@override
String toString() {
  return 'SellerRating(id: $id, buyerId: $buyerId, sellerId: $sellerId, productId: $productId, rating: $rating, review: $review, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SellerRatingCopyWith<$Res>  {
  factory $SellerRatingCopyWith(SellerRating value, $Res Function(SellerRating) _then) = _$SellerRatingCopyWithImpl;
@useResult
$Res call({
 String id, String buyerId, String sellerId, String productId, int rating, String? review, DateTime createdAt
});




}
/// @nodoc
class _$SellerRatingCopyWithImpl<$Res>
    implements $SellerRatingCopyWith<$Res> {
  _$SellerRatingCopyWithImpl(this._self, this._then);

  final SellerRating _self;
  final $Res Function(SellerRating) _then;

/// Create a copy of SellerRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? buyerId = null,Object? sellerId = null,Object? productId = null,Object? rating = null,Object? review = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerRating].
extension SellerRatingPatterns on SellerRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerRating value)  $default,){
final _that = this;
switch (_that) {
case _SellerRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerRating value)?  $default,){
final _that = this;
switch (_that) {
case _SellerRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String buyerId,  String sellerId,  String productId,  int rating,  String? review,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerRating() when $default != null:
return $default(_that.id,_that.buyerId,_that.sellerId,_that.productId,_that.rating,_that.review,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String buyerId,  String sellerId,  String productId,  int rating,  String? review,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SellerRating():
return $default(_that.id,_that.buyerId,_that.sellerId,_that.productId,_that.rating,_that.review,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String buyerId,  String sellerId,  String productId,  int rating,  String? review,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SellerRating() when $default != null:
return $default(_that.id,_that.buyerId,_that.sellerId,_that.productId,_that.rating,_that.review,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerRating implements SellerRating {
  const _SellerRating({required this.id, required this.buyerId, required this.sellerId, required this.productId, required this.rating, this.review, required this.createdAt});
  factory _SellerRating.fromJson(Map<String, dynamic> json) => _$SellerRatingFromJson(json);

@override final  String id;
@override final  String buyerId;
@override final  String sellerId;
@override final  String productId;
@override final  int rating;
@override final  String? review;
@override final  DateTime createdAt;

/// Create a copy of SellerRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerRatingCopyWith<_SellerRating> get copyWith => __$SellerRatingCopyWithImpl<_SellerRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerRatingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerRating&&(identical(other.id, id) || other.id == id)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,buyerId,sellerId,productId,rating,review,createdAt);

@override
String toString() {
  return 'SellerRating(id: $id, buyerId: $buyerId, sellerId: $sellerId, productId: $productId, rating: $rating, review: $review, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SellerRatingCopyWith<$Res> implements $SellerRatingCopyWith<$Res> {
  factory _$SellerRatingCopyWith(_SellerRating value, $Res Function(_SellerRating) _then) = __$SellerRatingCopyWithImpl;
@override @useResult
$Res call({
 String id, String buyerId, String sellerId, String productId, int rating, String? review, DateTime createdAt
});




}
/// @nodoc
class __$SellerRatingCopyWithImpl<$Res>
    implements _$SellerRatingCopyWith<$Res> {
  __$SellerRatingCopyWithImpl(this._self, this._then);

  final _SellerRating _self;
  final $Res Function(_SellerRating) _then;

/// Create a copy of SellerRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? buyerId = null,Object? sellerId = null,Object? productId = null,Object? rating = null,Object? review = freezed,Object? createdAt = null,}) {
  return _then(_SellerRating(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SellerRatingPage {

 List<SellerRating> get items; String? get nextCursor; double get averageRating;
/// Create a copy of SellerRatingPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerRatingPageCopyWith<SellerRatingPage> get copyWith => _$SellerRatingPageCopyWithImpl<SellerRatingPage>(this as SellerRatingPage, _$identity);

  /// Serializes this SellerRatingPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerRatingPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,averageRating);

@override
String toString() {
  return 'SellerRatingPage(items: $items, nextCursor: $nextCursor, averageRating: $averageRating)';
}


}

/// @nodoc
abstract mixin class $SellerRatingPageCopyWith<$Res>  {
  factory $SellerRatingPageCopyWith(SellerRatingPage value, $Res Function(SellerRatingPage) _then) = _$SellerRatingPageCopyWithImpl;
@useResult
$Res call({
 List<SellerRating> items, String? nextCursor, double averageRating
});




}
/// @nodoc
class _$SellerRatingPageCopyWithImpl<$Res>
    implements $SellerRatingPageCopyWith<$Res> {
  _$SellerRatingPageCopyWithImpl(this._self, this._then);

  final SellerRatingPage _self;
  final $Res Function(SellerRatingPage) _then;

/// Create a copy of SellerRatingPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? averageRating = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SellerRating>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerRatingPage].
extension SellerRatingPagePatterns on SellerRatingPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerRatingPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerRatingPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerRatingPage value)  $default,){
final _that = this;
switch (_that) {
case _SellerRatingPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerRatingPage value)?  $default,){
final _that = this;
switch (_that) {
case _SellerRatingPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SellerRating> items,  String? nextCursor,  double averageRating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerRatingPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.averageRating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SellerRating> items,  String? nextCursor,  double averageRating)  $default,) {final _that = this;
switch (_that) {
case _SellerRatingPage():
return $default(_that.items,_that.nextCursor,_that.averageRating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SellerRating> items,  String? nextCursor,  double averageRating)?  $default,) {final _that = this;
switch (_that) {
case _SellerRatingPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.averageRating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerRatingPage extends SellerRatingPage {
  const _SellerRatingPage({final  List<SellerRating> items = const <SellerRating>[], this.nextCursor, this.averageRating = 0}): _items = items,super._();
  factory _SellerRatingPage.fromJson(Map<String, dynamic> json) => _$SellerRatingPageFromJson(json);

 final  List<SellerRating> _items;
@override@JsonKey() List<SellerRating> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  double averageRating;

/// Create a copy of SellerRatingPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerRatingPageCopyWith<_SellerRatingPage> get copyWith => __$SellerRatingPageCopyWithImpl<_SellerRatingPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerRatingPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerRatingPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,averageRating);

@override
String toString() {
  return 'SellerRatingPage(items: $items, nextCursor: $nextCursor, averageRating: $averageRating)';
}


}

/// @nodoc
abstract mixin class _$SellerRatingPageCopyWith<$Res> implements $SellerRatingPageCopyWith<$Res> {
  factory _$SellerRatingPageCopyWith(_SellerRatingPage value, $Res Function(_SellerRatingPage) _then) = __$SellerRatingPageCopyWithImpl;
@override @useResult
$Res call({
 List<SellerRating> items, String? nextCursor, double averageRating
});




}
/// @nodoc
class __$SellerRatingPageCopyWithImpl<$Res>
    implements _$SellerRatingPageCopyWith<$Res> {
  __$SellerRatingPageCopyWithImpl(this._self, this._then);

  final _SellerRatingPage _self;
  final $Res Function(_SellerRatingPage) _then;

/// Create a copy of SellerRatingPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? averageRating = null,}) {
  return _then(_SellerRatingPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SellerRating>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
