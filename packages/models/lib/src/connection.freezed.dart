// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Connection {

 String get id; String get fromUserId; String get toUserId; ConnectionContext get context; ConnectionStatus get status; ModuleScope? get moduleScope; DateTime get createdAt;
/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionCopyWith<Connection> get copyWith => _$ConnectionCopyWithImpl<Connection>(this as Connection, _$identity);

  /// Serializes this Connection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Connection&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.context, context) || other.context == context)&&(identical(other.status, status) || other.status == status)&&(identical(other.moduleScope, moduleScope) || other.moduleScope == moduleScope)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,context,status,moduleScope,createdAt);

@override
String toString() {
  return 'Connection(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, context: $context, status: $status, moduleScope: $moduleScope, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ConnectionCopyWith<$Res>  {
  factory $ConnectionCopyWith(Connection value, $Res Function(Connection) _then) = _$ConnectionCopyWithImpl;
@useResult
$Res call({
 String id, String fromUserId, String toUserId, ConnectionContext context, ConnectionStatus status, ModuleScope? moduleScope, DateTime createdAt
});




}
/// @nodoc
class _$ConnectionCopyWithImpl<$Res>
    implements $ConnectionCopyWith<$Res> {
  _$ConnectionCopyWithImpl(this._self, this._then);

  final Connection _self;
  final $Res Function(Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? context = null,Object? status = null,Object? moduleScope = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ConnectionContext,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,moduleScope: freezed == moduleScope ? _self.moduleScope : moduleScope // ignore: cast_nullable_to_non_nullable
as ModuleScope?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Connection].
extension ConnectionPatterns on Connection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Connection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Connection value)  $default,){
final _that = this;
switch (_that) {
case _Connection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Connection value)?  $default,){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  ConnectionContext context,  ConnectionStatus status,  ModuleScope? moduleScope,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.context,_that.status,_that.moduleScope,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  ConnectionContext context,  ConnectionStatus status,  ModuleScope? moduleScope,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Connection():
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.context,_that.status,_that.moduleScope,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromUserId,  String toUserId,  ConnectionContext context,  ConnectionStatus status,  ModuleScope? moduleScope,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.context,_that.status,_that.moduleScope,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Connection implements Connection {
  const _Connection({required this.id, required this.fromUserId, required this.toUserId, required this.context, this.status = ConnectionStatus.pending, this.moduleScope, required this.createdAt});
  factory _Connection.fromJson(Map<String, dynamic> json) => _$ConnectionFromJson(json);

@override final  String id;
@override final  String fromUserId;
@override final  String toUserId;
@override final  ConnectionContext context;
@override@JsonKey() final  ConnectionStatus status;
@override final  ModuleScope? moduleScope;
@override final  DateTime createdAt;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionCopyWith<_Connection> get copyWith => __$ConnectionCopyWithImpl<_Connection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connection&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.context, context) || other.context == context)&&(identical(other.status, status) || other.status == status)&&(identical(other.moduleScope, moduleScope) || other.moduleScope == moduleScope)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,context,status,moduleScope,createdAt);

@override
String toString() {
  return 'Connection(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, context: $context, status: $status, moduleScope: $moduleScope, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ConnectionCopyWith<$Res> implements $ConnectionCopyWith<$Res> {
  factory _$ConnectionCopyWith(_Connection value, $Res Function(_Connection) _then) = __$ConnectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromUserId, String toUserId, ConnectionContext context, ConnectionStatus status, ModuleScope? moduleScope, DateTime createdAt
});




}
/// @nodoc
class __$ConnectionCopyWithImpl<$Res>
    implements _$ConnectionCopyWith<$Res> {
  __$ConnectionCopyWithImpl(this._self, this._then);

  final _Connection _self;
  final $Res Function(_Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? context = null,Object? status = null,Object? moduleScope = freezed,Object? createdAt = null,}) {
  return _then(_Connection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ConnectionContext,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,moduleScope: freezed == moduleScope ? _self.moduleScope : moduleScope // ignore: cast_nullable_to_non_nullable
as ModuleScope?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
