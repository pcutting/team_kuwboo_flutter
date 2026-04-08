// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get creatorId; String get title; String get description; int get priceCents; String get currency; String get condition; bool get isDeal; int? get originalPriceCents; String? get thumbnailUrl; String get status; int get likeCount; int get commentCount; DateTime get createdAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.isDeal, isDeal) || other.isDeal == isDeal)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,priceCents,currency,condition,isDeal,originalPriceCents,thumbnailUrl,status,likeCount,commentCount,createdAt);

@override
String toString() {
  return 'Product(id: $id, creatorId: $creatorId, title: $title, description: $description, priceCents: $priceCents, currency: $currency, condition: $condition, isDeal: $isDeal, originalPriceCents: $originalPriceCents, thumbnailUrl: $thumbnailUrl, status: $status, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String creatorId, String title, String description, int priceCents, String currency, String condition, bool isDeal, int? originalPriceCents, String? thumbnailUrl, String status, int likeCount, int commentCount, DateTime createdAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? currency = null,Object? condition = null,Object? isDeal = null,Object? originalPriceCents = freezed,Object? thumbnailUrl = freezed,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,isDeal: null == isDeal ? _self.isDeal : isDeal // ignore: cast_nullable_to_non_nullable
as bool,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  String description,  int priceCents,  String currency,  String condition,  bool isDeal,  int? originalPriceCents,  String? thumbnailUrl,  String status,  int likeCount,  int commentCount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.priceCents,_that.currency,_that.condition,_that.isDeal,_that.originalPriceCents,_that.thumbnailUrl,_that.status,_that.likeCount,_that.commentCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  String description,  int priceCents,  String currency,  String condition,  bool isDeal,  int? originalPriceCents,  String? thumbnailUrl,  String status,  int likeCount,  int commentCount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.priceCents,_that.currency,_that.condition,_that.isDeal,_that.originalPriceCents,_that.thumbnailUrl,_that.status,_that.likeCount,_that.commentCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creatorId,  String title,  String description,  int priceCents,  String currency,  String condition,  bool isDeal,  int? originalPriceCents,  String? thumbnailUrl,  String status,  int likeCount,  int commentCount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.priceCents,_that.currency,_that.condition,_that.isDeal,_that.originalPriceCents,_that.thumbnailUrl,_that.status,_that.likeCount,_that.commentCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.creatorId, required this.title, required this.description, required this.priceCents, this.currency = 'GBP', required this.condition, this.isDeal = false, this.originalPriceCents, this.thumbnailUrl, this.status = 'ACTIVE', this.likeCount = 0, this.commentCount = 0, required this.createdAt});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String creatorId;
@override final  String title;
@override final  String description;
@override final  int priceCents;
@override@JsonKey() final  String currency;
@override final  String condition;
@override@JsonKey() final  bool isDeal;
@override final  int? originalPriceCents;
@override final  String? thumbnailUrl;
@override@JsonKey() final  String status;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override final  DateTime createdAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.isDeal, isDeal) || other.isDeal == isDeal)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,priceCents,currency,condition,isDeal,originalPriceCents,thumbnailUrl,status,likeCount,commentCount,createdAt);

@override
String toString() {
  return 'Product(id: $id, creatorId: $creatorId, title: $title, description: $description, priceCents: $priceCents, currency: $currency, condition: $condition, isDeal: $isDeal, originalPriceCents: $originalPriceCents, thumbnailUrl: $thumbnailUrl, status: $status, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String creatorId, String title, String description, int priceCents, String currency, String condition, bool isDeal, int? originalPriceCents, String? thumbnailUrl, String status, int likeCount, int commentCount, DateTime createdAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? currency = null,Object? condition = null,Object? isDeal = null,Object? originalPriceCents = freezed,Object? thumbnailUrl = freezed,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,isDeal: null == isDeal ? _self.isDeal : isDeal // ignore: cast_nullable_to_non_nullable
as bool,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
