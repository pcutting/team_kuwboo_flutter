// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedResponse {

 List<Content> get items; String? get nextCursor; bool get hasMore;
/// Create a copy of FeedResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedResponseCopyWith<FeedResponse> get copyWith => _$FeedResponseCopyWithImpl<FeedResponse>(this as FeedResponse, _$identity);

  /// Serializes this FeedResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,hasMore);

@override
String toString() {
  return 'FeedResponse(items: $items, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $FeedResponseCopyWith<$Res>  {
  factory $FeedResponseCopyWith(FeedResponse value, $Res Function(FeedResponse) _then) = _$FeedResponseCopyWithImpl;
@useResult
$Res call({
 List<Content> items, String? nextCursor, bool hasMore
});




}
/// @nodoc
class _$FeedResponseCopyWithImpl<$Res>
    implements $FeedResponseCopyWith<$Res> {
  _$FeedResponseCopyWithImpl(this._self, this._then);

  final FeedResponse _self;
  final $Res Function(FeedResponse) _then;

/// Create a copy of FeedResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Content>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedResponse].
extension FeedResponsePatterns on FeedResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedResponse value)  $default,){
final _that = this;
switch (_that) {
case _FeedResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FeedResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Content> items,  String? nextCursor,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedResponse() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Content> items,  String? nextCursor,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _FeedResponse():
return $default(_that.items,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Content> items,  String? nextCursor,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _FeedResponse() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedResponse implements FeedResponse {
  const _FeedResponse({required final  List<Content> items, this.nextCursor, this.hasMore = false}): _items = items;
  factory _FeedResponse.fromJson(Map<String, dynamic> json) => _$FeedResponseFromJson(json);

 final  List<Content> _items;
@override List<Content> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;

/// Create a copy of FeedResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedResponseCopyWith<_FeedResponse> get copyWith => __$FeedResponseCopyWithImpl<_FeedResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore);

@override
String toString() {
  return 'FeedResponse(items: $items, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$FeedResponseCopyWith<$Res> implements $FeedResponseCopyWith<$Res> {
  factory _$FeedResponseCopyWith(_FeedResponse value, $Res Function(_FeedResponse) _then) = __$FeedResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Content> items, String? nextCursor, bool hasMore
});




}
/// @nodoc
class __$FeedResponseCopyWithImpl<$Res>
    implements _$FeedResponseCopyWith<$Res> {
  __$FeedResponseCopyWithImpl(this._self, this._then);

  final _FeedResponse _self;
  final $Res Function(_FeedResponse) _then;

/// Create a copy of FeedResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_FeedResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Content>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
