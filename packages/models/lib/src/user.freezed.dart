// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String? get phone; String? get email; String? get name; String? get avatarUrl; String? get bio; String? get username; DateTime? get dateOfBirth; bool get birthdaySkipped; OnboardingProgress get onboardingProgress; int get profileCompletenessPct; int get tutorialVersion; DateTime? get tutorialCompletedAt; AgeVerificationStatus get ageVerificationStatus; Role get role; UserStatus get status; OnlineStatus get onlineStatus; bool get isBot; DateTime? get lastLoginAt; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.username, username) || other.username == username)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress)&&(identical(other.profileCompletenessPct, profileCompletenessPct) || other.profileCompletenessPct == profileCompletenessPct)&&(identical(other.tutorialVersion, tutorialVersion) || other.tutorialVersion == tutorialVersion)&&(identical(other.tutorialCompletedAt, tutorialCompletedAt) || other.tutorialCompletedAt == tutorialCompletedAt)&&(identical(other.ageVerificationStatus, ageVerificationStatus) || other.ageVerificationStatus == ageVerificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,phone,email,name,avatarUrl,bio,username,dateOfBirth,birthdaySkipped,onboardingProgress,profileCompletenessPct,tutorialVersion,tutorialCompletedAt,ageVerificationStatus,role,status,onlineStatus,isBot,lastLoginAt,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, phone: $phone, email: $email, name: $name, avatarUrl: $avatarUrl, bio: $bio, username: $username, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress, profileCompletenessPct: $profileCompletenessPct, tutorialVersion: $tutorialVersion, tutorialCompletedAt: $tutorialCompletedAt, ageVerificationStatus: $ageVerificationStatus, role: $role, status: $status, onlineStatus: $onlineStatus, isBot: $isBot, lastLoginAt: $lastLoginAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? email, String? name, String? avatarUrl, String? bio, String? username, DateTime? dateOfBirth, bool birthdaySkipped, OnboardingProgress onboardingProgress, int profileCompletenessPct, int tutorialVersion, DateTime? tutorialCompletedAt, AgeVerificationStatus ageVerificationStatus, Role role, UserStatus status, OnlineStatus onlineStatus, bool isBot, DateTime? lastLoginAt, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? email = freezed,Object? name = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? username = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = null,Object? onboardingProgress = null,Object? profileCompletenessPct = null,Object? tutorialVersion = null,Object? tutorialCompletedAt = freezed,Object? ageVerificationStatus = null,Object? role = null,Object? status = null,Object? onlineStatus = null,Object? isBot = null,Object? lastLoginAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,birthdaySkipped: null == birthdaySkipped ? _self.birthdaySkipped : birthdaySkipped // ignore: cast_nullable_to_non_nullable
as bool,onboardingProgress: null == onboardingProgress ? _self.onboardingProgress : onboardingProgress // ignore: cast_nullable_to_non_nullable
as OnboardingProgress,profileCompletenessPct: null == profileCompletenessPct ? _self.profileCompletenessPct : profileCompletenessPct // ignore: cast_nullable_to_non_nullable
as int,tutorialVersion: null == tutorialVersion ? _self.tutorialVersion : tutorialVersion // ignore: cast_nullable_to_non_nullable
as int,tutorialCompletedAt: freezed == tutorialCompletedAt ? _self.tutorialCompletedAt : tutorialCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ageVerificationStatus: null == ageVerificationStatus ? _self.ageVerificationStatus : ageVerificationStatus // ignore: cast_nullable_to_non_nullable
as AgeVerificationStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as OnlineStatus,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, this.phone, this.email, this.name, this.avatarUrl, this.bio, this.username, this.dateOfBirth, this.birthdaySkipped = false, this.onboardingProgress = OnboardingProgress.welcome, this.profileCompletenessPct = 0, this.tutorialVersion = 0, this.tutorialCompletedAt, this.ageVerificationStatus = AgeVerificationStatus.selfDeclared, this.role = Role.user, this.status = UserStatus.active, this.onlineStatus = OnlineStatus.offline, this.isBot = false, this.lastLoginAt, required this.createdAt, this.updatedAt});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String? email;
@override final  String? name;
@override final  String? avatarUrl;
@override final  String? bio;
@override final  String? username;
@override final  DateTime? dateOfBirth;
@override@JsonKey() final  bool birthdaySkipped;
@override@JsonKey() final  OnboardingProgress onboardingProgress;
@override@JsonKey() final  int profileCompletenessPct;
@override@JsonKey() final  int tutorialVersion;
@override final  DateTime? tutorialCompletedAt;
@override@JsonKey() final  AgeVerificationStatus ageVerificationStatus;
@override@JsonKey() final  Role role;
@override@JsonKey() final  UserStatus status;
@override@JsonKey() final  OnlineStatus onlineStatus;
@override@JsonKey() final  bool isBot;
@override final  DateTime? lastLoginAt;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.username, username) || other.username == username)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress)&&(identical(other.profileCompletenessPct, profileCompletenessPct) || other.profileCompletenessPct == profileCompletenessPct)&&(identical(other.tutorialVersion, tutorialVersion) || other.tutorialVersion == tutorialVersion)&&(identical(other.tutorialCompletedAt, tutorialCompletedAt) || other.tutorialCompletedAt == tutorialCompletedAt)&&(identical(other.ageVerificationStatus, ageVerificationStatus) || other.ageVerificationStatus == ageVerificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,phone,email,name,avatarUrl,bio,username,dateOfBirth,birthdaySkipped,onboardingProgress,profileCompletenessPct,tutorialVersion,tutorialCompletedAt,ageVerificationStatus,role,status,onlineStatus,isBot,lastLoginAt,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, phone: $phone, email: $email, name: $name, avatarUrl: $avatarUrl, bio: $bio, username: $username, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress, profileCompletenessPct: $profileCompletenessPct, tutorialVersion: $tutorialVersion, tutorialCompletedAt: $tutorialCompletedAt, ageVerificationStatus: $ageVerificationStatus, role: $role, status: $status, onlineStatus: $onlineStatus, isBot: $isBot, lastLoginAt: $lastLoginAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? email, String? name, String? avatarUrl, String? bio, String? username, DateTime? dateOfBirth, bool birthdaySkipped, OnboardingProgress onboardingProgress, int profileCompletenessPct, int tutorialVersion, DateTime? tutorialCompletedAt, AgeVerificationStatus ageVerificationStatus, Role role, UserStatus status, OnlineStatus onlineStatus, bool isBot, DateTime? lastLoginAt, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? email = freezed,Object? name = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? username = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = null,Object? onboardingProgress = null,Object? profileCompletenessPct = null,Object? tutorialVersion = null,Object? tutorialCompletedAt = freezed,Object? ageVerificationStatus = null,Object? role = null,Object? status = null,Object? onlineStatus = null,Object? isBot = null,Object? lastLoginAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,birthdaySkipped: null == birthdaySkipped ? _self.birthdaySkipped : birthdaySkipped // ignore: cast_nullable_to_non_nullable
as bool,onboardingProgress: null == onboardingProgress ? _self.onboardingProgress : onboardingProgress // ignore: cast_nullable_to_non_nullable
as OnboardingProgress,profileCompletenessPct: null == profileCompletenessPct ? _self.profileCompletenessPct : profileCompletenessPct // ignore: cast_nullable_to_non_nullable
as int,tutorialVersion: null == tutorialVersion ? _self.tutorialVersion : tutorialVersion // ignore: cast_nullable_to_non_nullable
as int,tutorialCompletedAt: freezed == tutorialCompletedAt ? _self.tutorialCompletedAt : tutorialCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ageVerificationStatus: null == ageVerificationStatus ? _self.ageVerificationStatus : ageVerificationStatus // ignore: cast_nullable_to_non_nullable
as AgeVerificationStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as OnlineStatus,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
