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

 String get id; String? get phone; String? get email; String? get name; String? get avatarUrl; String? get bio; String? get username; DateTime? get dateOfBirth; bool get birthdaySkipped; OnboardingProgress get onboardingProgress; int get profileCompletenessPct; int get tutorialVersion; DateTime? get tutorialCompletedAt; AgeVerificationStatus get ageVerificationStatus; Role get role; UserStatus get status; OnlineStatus get onlineStatus; bool get isBot; String? get googleId; String? get appleId; bool get appleEmailIsPrivateRelay; DateTime? get appleConsentRevokedAt; DateTime? get appleAccountDeletedAt; DateTime? get lastReminderAt; DateTime? get lastProfileReminderAt; DateTime? get lastLoginAt; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.username, username) || other.username == username)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress)&&(identical(other.profileCompletenessPct, profileCompletenessPct) || other.profileCompletenessPct == profileCompletenessPct)&&(identical(other.tutorialVersion, tutorialVersion) || other.tutorialVersion == tutorialVersion)&&(identical(other.tutorialCompletedAt, tutorialCompletedAt) || other.tutorialCompletedAt == tutorialCompletedAt)&&(identical(other.ageVerificationStatus, ageVerificationStatus) || other.ageVerificationStatus == ageVerificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.googleId, googleId) || other.googleId == googleId)&&(identical(other.appleId, appleId) || other.appleId == appleId)&&(identical(other.appleEmailIsPrivateRelay, appleEmailIsPrivateRelay) || other.appleEmailIsPrivateRelay == appleEmailIsPrivateRelay)&&(identical(other.appleConsentRevokedAt, appleConsentRevokedAt) || other.appleConsentRevokedAt == appleConsentRevokedAt)&&(identical(other.appleAccountDeletedAt, appleAccountDeletedAt) || other.appleAccountDeletedAt == appleAccountDeletedAt)&&(identical(other.lastReminderAt, lastReminderAt) || other.lastReminderAt == lastReminderAt)&&(identical(other.lastProfileReminderAt, lastProfileReminderAt) || other.lastProfileReminderAt == lastProfileReminderAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,phone,email,name,avatarUrl,bio,username,dateOfBirth,birthdaySkipped,onboardingProgress,profileCompletenessPct,tutorialVersion,tutorialCompletedAt,ageVerificationStatus,role,status,onlineStatus,isBot,googleId,appleId,appleEmailIsPrivateRelay,appleConsentRevokedAt,appleAccountDeletedAt,lastReminderAt,lastProfileReminderAt,lastLoginAt,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, phone: $phone, email: $email, name: $name, avatarUrl: $avatarUrl, bio: $bio, username: $username, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress, profileCompletenessPct: $profileCompletenessPct, tutorialVersion: $tutorialVersion, tutorialCompletedAt: $tutorialCompletedAt, ageVerificationStatus: $ageVerificationStatus, role: $role, status: $status, onlineStatus: $onlineStatus, isBot: $isBot, googleId: $googleId, appleId: $appleId, appleEmailIsPrivateRelay: $appleEmailIsPrivateRelay, appleConsentRevokedAt: $appleConsentRevokedAt, appleAccountDeletedAt: $appleAccountDeletedAt, lastReminderAt: $lastReminderAt, lastProfileReminderAt: $lastProfileReminderAt, lastLoginAt: $lastLoginAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? email, String? name, String? avatarUrl, String? bio, String? username, DateTime? dateOfBirth, bool birthdaySkipped, OnboardingProgress onboardingProgress, int profileCompletenessPct, int tutorialVersion, DateTime? tutorialCompletedAt, AgeVerificationStatus ageVerificationStatus, Role role, UserStatus status, OnlineStatus onlineStatus, bool isBot, String? googleId, String? appleId, bool appleEmailIsPrivateRelay, DateTime? appleConsentRevokedAt, DateTime? appleAccountDeletedAt, DateTime? lastReminderAt, DateTime? lastProfileReminderAt, DateTime? lastLoginAt, DateTime createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? email = freezed,Object? name = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? username = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = null,Object? onboardingProgress = null,Object? profileCompletenessPct = null,Object? tutorialVersion = null,Object? tutorialCompletedAt = freezed,Object? ageVerificationStatus = null,Object? role = null,Object? status = null,Object? onlineStatus = null,Object? isBot = null,Object? googleId = freezed,Object? appleId = freezed,Object? appleEmailIsPrivateRelay = null,Object? appleConsentRevokedAt = freezed,Object? appleAccountDeletedAt = freezed,Object? lastReminderAt = freezed,Object? lastProfileReminderAt = freezed,Object? lastLoginAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
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
as bool,googleId: freezed == googleId ? _self.googleId : googleId // ignore: cast_nullable_to_non_nullable
as String?,appleId: freezed == appleId ? _self.appleId : appleId // ignore: cast_nullable_to_non_nullable
as String?,appleEmailIsPrivateRelay: null == appleEmailIsPrivateRelay ? _self.appleEmailIsPrivateRelay : appleEmailIsPrivateRelay // ignore: cast_nullable_to_non_nullable
as bool,appleConsentRevokedAt: freezed == appleConsentRevokedAt ? _self.appleConsentRevokedAt : appleConsentRevokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appleAccountDeletedAt: freezed == appleAccountDeletedAt ? _self.appleAccountDeletedAt : appleAccountDeletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReminderAt: freezed == lastReminderAt ? _self.lastReminderAt : lastReminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastProfileReminderAt: freezed == lastProfileReminderAt ? _self.lastProfileReminderAt : lastProfileReminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  String? googleId,  String? appleId,  bool appleEmailIsPrivateRelay,  DateTime? appleConsentRevokedAt,  DateTime? appleAccountDeletedAt,  DateTime? lastReminderAt,  DateTime? lastProfileReminderAt,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.googleId,_that.appleId,_that.appleEmailIsPrivateRelay,_that.appleConsentRevokedAt,_that.appleAccountDeletedAt,_that.lastReminderAt,_that.lastProfileReminderAt,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  String? googleId,  String? appleId,  bool appleEmailIsPrivateRelay,  DateTime? appleConsentRevokedAt,  DateTime? appleAccountDeletedAt,  DateTime? lastReminderAt,  DateTime? lastProfileReminderAt,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.googleId,_that.appleId,_that.appleEmailIsPrivateRelay,_that.appleConsentRevokedAt,_that.appleAccountDeletedAt,_that.lastReminderAt,_that.lastProfileReminderAt,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String? email,  String? name,  String? avatarUrl,  String? bio,  String? username,  DateTime? dateOfBirth,  bool birthdaySkipped,  OnboardingProgress onboardingProgress,  int profileCompletenessPct,  int tutorialVersion,  DateTime? tutorialCompletedAt,  AgeVerificationStatus ageVerificationStatus,  Role role,  UserStatus status,  OnlineStatus onlineStatus,  bool isBot,  String? googleId,  String? appleId,  bool appleEmailIsPrivateRelay,  DateTime? appleConsentRevokedAt,  DateTime? appleAccountDeletedAt,  DateTime? lastReminderAt,  DateTime? lastProfileReminderAt,  DateTime? lastLoginAt,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.email,_that.name,_that.avatarUrl,_that.bio,_that.username,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress,_that.profileCompletenessPct,_that.tutorialVersion,_that.tutorialCompletedAt,_that.ageVerificationStatus,_that.role,_that.status,_that.onlineStatus,_that.isBot,_that.googleId,_that.appleId,_that.appleEmailIsPrivateRelay,_that.appleConsentRevokedAt,_that.appleAccountDeletedAt,_that.lastReminderAt,_that.lastProfileReminderAt,_that.lastLoginAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, this.phone, this.email, this.name, this.avatarUrl, this.bio, this.username, this.dateOfBirth, this.birthdaySkipped = false, this.onboardingProgress = OnboardingProgress.welcome, this.profileCompletenessPct = 0, this.tutorialVersion = 0, this.tutorialCompletedAt, this.ageVerificationStatus = AgeVerificationStatus.selfDeclared, this.role = Role.user, this.status = UserStatus.active, this.onlineStatus = OnlineStatus.offline, this.isBot = false, this.googleId, this.appleId, this.appleEmailIsPrivateRelay = false, this.appleConsentRevokedAt, this.appleAccountDeletedAt, this.lastReminderAt, this.lastProfileReminderAt, this.lastLoginAt, required this.createdAt, this.updatedAt});
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
@override final  String? googleId;
@override final  String? appleId;
@override@JsonKey() final  bool appleEmailIsPrivateRelay;
@override final  DateTime? appleConsentRevokedAt;
@override final  DateTime? appleAccountDeletedAt;
@override final  DateTime? lastReminderAt;
@override final  DateTime? lastProfileReminderAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.username, username) || other.username == username)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress)&&(identical(other.profileCompletenessPct, profileCompletenessPct) || other.profileCompletenessPct == profileCompletenessPct)&&(identical(other.tutorialVersion, tutorialVersion) || other.tutorialVersion == tutorialVersion)&&(identical(other.tutorialCompletedAt, tutorialCompletedAt) || other.tutorialCompletedAt == tutorialCompletedAt)&&(identical(other.ageVerificationStatus, ageVerificationStatus) || other.ageVerificationStatus == ageVerificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.googleId, googleId) || other.googleId == googleId)&&(identical(other.appleId, appleId) || other.appleId == appleId)&&(identical(other.appleEmailIsPrivateRelay, appleEmailIsPrivateRelay) || other.appleEmailIsPrivateRelay == appleEmailIsPrivateRelay)&&(identical(other.appleConsentRevokedAt, appleConsentRevokedAt) || other.appleConsentRevokedAt == appleConsentRevokedAt)&&(identical(other.appleAccountDeletedAt, appleAccountDeletedAt) || other.appleAccountDeletedAt == appleAccountDeletedAt)&&(identical(other.lastReminderAt, lastReminderAt) || other.lastReminderAt == lastReminderAt)&&(identical(other.lastProfileReminderAt, lastProfileReminderAt) || other.lastProfileReminderAt == lastProfileReminderAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,phone,email,name,avatarUrl,bio,username,dateOfBirth,birthdaySkipped,onboardingProgress,profileCompletenessPct,tutorialVersion,tutorialCompletedAt,ageVerificationStatus,role,status,onlineStatus,isBot,googleId,appleId,appleEmailIsPrivateRelay,appleConsentRevokedAt,appleAccountDeletedAt,lastReminderAt,lastProfileReminderAt,lastLoginAt,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, phone: $phone, email: $email, name: $name, avatarUrl: $avatarUrl, bio: $bio, username: $username, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress, profileCompletenessPct: $profileCompletenessPct, tutorialVersion: $tutorialVersion, tutorialCompletedAt: $tutorialCompletedAt, ageVerificationStatus: $ageVerificationStatus, role: $role, status: $status, onlineStatus: $onlineStatus, isBot: $isBot, googleId: $googleId, appleId: $appleId, appleEmailIsPrivateRelay: $appleEmailIsPrivateRelay, appleConsentRevokedAt: $appleConsentRevokedAt, appleAccountDeletedAt: $appleAccountDeletedAt, lastReminderAt: $lastReminderAt, lastProfileReminderAt: $lastProfileReminderAt, lastLoginAt: $lastLoginAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? email, String? name, String? avatarUrl, String? bio, String? username, DateTime? dateOfBirth, bool birthdaySkipped, OnboardingProgress onboardingProgress, int profileCompletenessPct, int tutorialVersion, DateTime? tutorialCompletedAt, AgeVerificationStatus ageVerificationStatus, Role role, UserStatus status, OnlineStatus onlineStatus, bool isBot, String? googleId, String? appleId, bool appleEmailIsPrivateRelay, DateTime? appleConsentRevokedAt, DateTime? appleAccountDeletedAt, DateTime? lastReminderAt, DateTime? lastProfileReminderAt, DateTime? lastLoginAt, DateTime createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? email = freezed,Object? name = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? username = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = null,Object? onboardingProgress = null,Object? profileCompletenessPct = null,Object? tutorialVersion = null,Object? tutorialCompletedAt = freezed,Object? ageVerificationStatus = null,Object? role = null,Object? status = null,Object? onlineStatus = null,Object? isBot = null,Object? googleId = freezed,Object? appleId = freezed,Object? appleEmailIsPrivateRelay = null,Object? appleConsentRevokedAt = freezed,Object? appleAccountDeletedAt = freezed,Object? lastReminderAt = freezed,Object? lastProfileReminderAt = freezed,Object? lastLoginAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
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
as bool,googleId: freezed == googleId ? _self.googleId : googleId // ignore: cast_nullable_to_non_nullable
as String?,appleId: freezed == appleId ? _self.appleId : appleId // ignore: cast_nullable_to_non_nullable
as String?,appleEmailIsPrivateRelay: null == appleEmailIsPrivateRelay ? _self.appleEmailIsPrivateRelay : appleEmailIsPrivateRelay // ignore: cast_nullable_to_non_nullable
as bool,appleConsentRevokedAt: freezed == appleConsentRevokedAt ? _self.appleConsentRevokedAt : appleConsentRevokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appleAccountDeletedAt: freezed == appleAccountDeletedAt ? _self.appleAccountDeletedAt : appleAccountDeletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReminderAt: freezed == lastReminderAt ? _self.lastReminderAt : lastReminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastProfileReminderAt: freezed == lastProfileReminderAt ? _self.lastProfileReminderAt : lastProfileReminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PatchMeDto {

 String? get displayName; String? get username; String? get avatarUrl; String? get bio; String? get dateOfBirth; bool? get birthdaySkipped; OnboardingProgress? get onboardingProgress;
/// Create a copy of PatchMeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchMeDtoCopyWith<PatchMeDto> get copyWith => _$PatchMeDtoCopyWithImpl<PatchMeDto>(this as PatchMeDto, _$identity);

  /// Serializes this PatchMeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchMeDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,username,avatarUrl,bio,dateOfBirth,birthdaySkipped,onboardingProgress);

@override
String toString() {
  return 'PatchMeDto(displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress)';
}


}

/// @nodoc
abstract mixin class $PatchMeDtoCopyWith<$Res>  {
  factory $PatchMeDtoCopyWith(PatchMeDto value, $Res Function(PatchMeDto) _then) = _$PatchMeDtoCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? username, String? avatarUrl, String? bio, String? dateOfBirth, bool? birthdaySkipped, OnboardingProgress? onboardingProgress
});




}
/// @nodoc
class _$PatchMeDtoCopyWithImpl<$Res>
    implements $PatchMeDtoCopyWith<$Res> {
  _$PatchMeDtoCopyWithImpl(this._self, this._then);

  final PatchMeDto _self;
  final $Res Function(PatchMeDto) _then;

/// Create a copy of PatchMeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = freezed,Object? onboardingProgress = freezed,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,birthdaySkipped: freezed == birthdaySkipped ? _self.birthdaySkipped : birthdaySkipped // ignore: cast_nullable_to_non_nullable
as bool?,onboardingProgress: freezed == onboardingProgress ? _self.onboardingProgress : onboardingProgress // ignore: cast_nullable_to_non_nullable
as OnboardingProgress?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatchMeDto].
extension PatchMeDtoPatterns on PatchMeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchMeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchMeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchMeDto value)  $default,){
final _that = this;
switch (_that) {
case _PatchMeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchMeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PatchMeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? dateOfBirth,  bool? birthdaySkipped,  OnboardingProgress? onboardingProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchMeDto() when $default != null:
return $default(_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? dateOfBirth,  bool? birthdaySkipped,  OnboardingProgress? onboardingProgress)  $default,) {final _that = this;
switch (_that) {
case _PatchMeDto():
return $default(_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? dateOfBirth,  bool? birthdaySkipped,  OnboardingProgress? onboardingProgress)?  $default,) {final _that = this;
switch (_that) {
case _PatchMeDto() when $default != null:
return $default(_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.dateOfBirth,_that.birthdaySkipped,_that.onboardingProgress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatchMeDto implements PatchMeDto {
  const _PatchMeDto({this.displayName, this.username, this.avatarUrl, this.bio, this.dateOfBirth, this.birthdaySkipped, this.onboardingProgress});
  factory _PatchMeDto.fromJson(Map<String, dynamic> json) => _$PatchMeDtoFromJson(json);

@override final  String? displayName;
@override final  String? username;
@override final  String? avatarUrl;
@override final  String? bio;
@override final  String? dateOfBirth;
@override final  bool? birthdaySkipped;
@override final  OnboardingProgress? onboardingProgress;

/// Create a copy of PatchMeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchMeDtoCopyWith<_PatchMeDto> get copyWith => __$PatchMeDtoCopyWithImpl<_PatchMeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatchMeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchMeDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.birthdaySkipped, birthdaySkipped) || other.birthdaySkipped == birthdaySkipped)&&(identical(other.onboardingProgress, onboardingProgress) || other.onboardingProgress == onboardingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,username,avatarUrl,bio,dateOfBirth,birthdaySkipped,onboardingProgress);

@override
String toString() {
  return 'PatchMeDto(displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, dateOfBirth: $dateOfBirth, birthdaySkipped: $birthdaySkipped, onboardingProgress: $onboardingProgress)';
}


}

/// @nodoc
abstract mixin class _$PatchMeDtoCopyWith<$Res> implements $PatchMeDtoCopyWith<$Res> {
  factory _$PatchMeDtoCopyWith(_PatchMeDto value, $Res Function(_PatchMeDto) _then) = __$PatchMeDtoCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? username, String? avatarUrl, String? bio, String? dateOfBirth, bool? birthdaySkipped, OnboardingProgress? onboardingProgress
});




}
/// @nodoc
class __$PatchMeDtoCopyWithImpl<$Res>
    implements _$PatchMeDtoCopyWith<$Res> {
  __$PatchMeDtoCopyWithImpl(this._self, this._then);

  final _PatchMeDto _self;
  final $Res Function(_PatchMeDto) _then;

/// Create a copy of PatchMeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? birthdaySkipped = freezed,Object? onboardingProgress = freezed,}) {
  return _then(_PatchMeDto(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,birthdaySkipped: freezed == birthdaySkipped ? _self.birthdaySkipped : birthdaySkipped // ignore: cast_nullable_to_non_nullable
as bool?,onboardingProgress: freezed == onboardingProgress ? _self.onboardingProgress : onboardingProgress // ignore: cast_nullable_to_non_nullable
as OnboardingProgress?,
  ));
}


}


/// @nodoc
mixin _$TutorialCompleteDto {

 int get version;
/// Create a copy of TutorialCompleteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialCompleteDtoCopyWith<TutorialCompleteDto> get copyWith => _$TutorialCompleteDtoCopyWithImpl<TutorialCompleteDto>(this as TutorialCompleteDto, _$identity);

  /// Serializes this TutorialCompleteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialCompleteDto&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version);

@override
String toString() {
  return 'TutorialCompleteDto(version: $version)';
}


}

/// @nodoc
abstract mixin class $TutorialCompleteDtoCopyWith<$Res>  {
  factory $TutorialCompleteDtoCopyWith(TutorialCompleteDto value, $Res Function(TutorialCompleteDto) _then) = _$TutorialCompleteDtoCopyWithImpl;
@useResult
$Res call({
 int version
});




}
/// @nodoc
class _$TutorialCompleteDtoCopyWithImpl<$Res>
    implements $TutorialCompleteDtoCopyWith<$Res> {
  _$TutorialCompleteDtoCopyWithImpl(this._self, this._then);

  final TutorialCompleteDto _self;
  final $Res Function(TutorialCompleteDto) _then;

/// Create a copy of TutorialCompleteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialCompleteDto].
extension TutorialCompleteDtoPatterns on TutorialCompleteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialCompleteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialCompleteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialCompleteDto value)  $default,){
final _that = this;
switch (_that) {
case _TutorialCompleteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialCompleteDto value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialCompleteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialCompleteDto() when $default != null:
return $default(_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version)  $default,) {final _that = this;
switch (_that) {
case _TutorialCompleteDto():
return $default(_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version)?  $default,) {final _that = this;
switch (_that) {
case _TutorialCompleteDto() when $default != null:
return $default(_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialCompleteDto implements TutorialCompleteDto {
  const _TutorialCompleteDto({required this.version});
  factory _TutorialCompleteDto.fromJson(Map<String, dynamic> json) => _$TutorialCompleteDtoFromJson(json);

@override final  int version;

/// Create a copy of TutorialCompleteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialCompleteDtoCopyWith<_TutorialCompleteDto> get copyWith => __$TutorialCompleteDtoCopyWithImpl<_TutorialCompleteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialCompleteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialCompleteDto&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version);

@override
String toString() {
  return 'TutorialCompleteDto(version: $version)';
}


}

/// @nodoc
abstract mixin class _$TutorialCompleteDtoCopyWith<$Res> implements $TutorialCompleteDtoCopyWith<$Res> {
  factory _$TutorialCompleteDtoCopyWith(_TutorialCompleteDto value, $Res Function(_TutorialCompleteDto) _then) = __$TutorialCompleteDtoCopyWithImpl;
@override @useResult
$Res call({
 int version
});




}
/// @nodoc
class __$TutorialCompleteDtoCopyWithImpl<$Res>
    implements _$TutorialCompleteDtoCopyWith<$Res> {
  __$TutorialCompleteDtoCopyWithImpl(this._self, this._then);

  final _TutorialCompleteDto _self;
  final $Res Function(_TutorialCompleteDto) _then;

/// Create a copy of TutorialCompleteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,}) {
  return _then(_TutorialCompleteDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UpdateUserDto {

 String? get name; String? get avatarUrl; String? get dateOfBirth; double? get latitude; double? get longitude;
/// Create a copy of UpdateUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserDtoCopyWith<UpdateUserDto> get copyWith => _$UpdateUserDtoCopyWithImpl<UpdateUserDto>(this as UpdateUserDto, _$identity);

  /// Serializes this UpdateUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserDto&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,dateOfBirth,latitude,longitude);

@override
String toString() {
  return 'UpdateUserDto(name: $name, avatarUrl: $avatarUrl, dateOfBirth: $dateOfBirth, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $UpdateUserDtoCopyWith<$Res>  {
  factory $UpdateUserDtoCopyWith(UpdateUserDto value, $Res Function(UpdateUserDto) _then) = _$UpdateUserDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? avatarUrl, String? dateOfBirth, double? latitude, double? longitude
});




}
/// @nodoc
class _$UpdateUserDtoCopyWithImpl<$Res>
    implements $UpdateUserDtoCopyWith<$Res> {
  _$UpdateUserDtoCopyWithImpl(this._self, this._then);

  final UpdateUserDto _self;
  final $Res Function(UpdateUserDto) _then;

/// Create a copy of UpdateUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? avatarUrl = freezed,Object? dateOfBirth = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserDto].
extension UpdateUserDtoPatterns on UpdateUserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? avatarUrl,  String? dateOfBirth,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserDto() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.dateOfBirth,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? avatarUrl,  String? dateOfBirth,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserDto():
return $default(_that.name,_that.avatarUrl,_that.dateOfBirth,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? avatarUrl,  String? dateOfBirth,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserDto() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.dateOfBirth,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserDto implements UpdateUserDto {
  const _UpdateUserDto({this.name, this.avatarUrl, this.dateOfBirth, this.latitude, this.longitude});
  factory _UpdateUserDto.fromJson(Map<String, dynamic> json) => _$UpdateUserDtoFromJson(json);

@override final  String? name;
@override final  String? avatarUrl;
@override final  String? dateOfBirth;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of UpdateUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserDtoCopyWith<_UpdateUserDto> get copyWith => __$UpdateUserDtoCopyWithImpl<_UpdateUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserDto&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,dateOfBirth,latitude,longitude);

@override
String toString() {
  return 'UpdateUserDto(name: $name, avatarUrl: $avatarUrl, dateOfBirth: $dateOfBirth, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserDtoCopyWith<$Res> implements $UpdateUserDtoCopyWith<$Res> {
  factory _$UpdateUserDtoCopyWith(_UpdateUserDto value, $Res Function(_UpdateUserDto) _then) = __$UpdateUserDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? avatarUrl, String? dateOfBirth, double? latitude, double? longitude
});




}
/// @nodoc
class __$UpdateUserDtoCopyWithImpl<$Res>
    implements _$UpdateUserDtoCopyWith<$Res> {
  __$UpdateUserDtoCopyWithImpl(this._self, this._then);

  final _UpdateUserDto _self;
  final $Res Function(_UpdateUserDto) _then;

/// Create a copy of UpdateUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? avatarUrl = freezed,Object? dateOfBirth = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_UpdateUserDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$NotificationPreferences {

 bool? get likes; bool? get comments; bool? get follows; bool? get messages; bool? get marketing;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.follows, follows) || other.follows == follows)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.marketing, marketing) || other.marketing == marketing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,comments,follows,messages,marketing);

@override
String toString() {
  return 'NotificationPreferences(likes: $likes, comments: $comments, follows: $follows, messages: $messages, marketing: $marketing)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool? likes, bool? comments, bool? follows, bool? messages, bool? marketing
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likes = freezed,Object? comments = freezed,Object? follows = freezed,Object? messages = freezed,Object? marketing = freezed,}) {
  return _then(_self.copyWith(
likes: freezed == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as bool?,comments: freezed == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as bool?,follows: freezed == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as bool?,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as bool?,marketing: freezed == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? likes,  bool? comments,  bool? follows,  bool? messages,  bool? marketing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.likes,_that.comments,_that.follows,_that.messages,_that.marketing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? likes,  bool? comments,  bool? follows,  bool? messages,  bool? marketing)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.likes,_that.comments,_that.follows,_that.messages,_that.marketing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? likes,  bool? comments,  bool? follows,  bool? messages,  bool? marketing)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.likes,_that.comments,_that.follows,_that.messages,_that.marketing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences implements NotificationPreferences {
  const _NotificationPreferences({this.likes, this.comments, this.follows, this.messages, this.marketing});
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override final  bool? likes;
@override final  bool? comments;
@override final  bool? follows;
@override final  bool? messages;
@override final  bool? marketing;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.follows, follows) || other.follows == follows)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.marketing, marketing) || other.marketing == marketing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,comments,follows,messages,marketing);

@override
String toString() {
  return 'NotificationPreferences(likes: $likes, comments: $comments, follows: $follows, messages: $messages, marketing: $marketing)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool? likes, bool? comments, bool? follows, bool? messages, bool? marketing
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likes = freezed,Object? comments = freezed,Object? follows = freezed,Object? messages = freezed,Object? marketing = freezed,}) {
  return _then(_NotificationPreferences(
likes: freezed == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as bool?,comments: freezed == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as bool?,follows: freezed == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as bool?,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as bool?,marketing: freezed == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$PrivacyPreferences {

 bool? get showOnlineStatus; bool? get showLastActive; bool? get showLocation; bool? get allowStrangerMessages;
/// Create a copy of PrivacyPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacyPreferencesCopyWith<PrivacyPreferences> get copyWith => _$PrivacyPreferencesCopyWithImpl<PrivacyPreferences>(this as PrivacyPreferences, _$identity);

  /// Serializes this PrivacyPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacyPreferences&&(identical(other.showOnlineStatus, showOnlineStatus) || other.showOnlineStatus == showOnlineStatus)&&(identical(other.showLastActive, showLastActive) || other.showLastActive == showLastActive)&&(identical(other.showLocation, showLocation) || other.showLocation == showLocation)&&(identical(other.allowStrangerMessages, allowStrangerMessages) || other.allowStrangerMessages == allowStrangerMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showOnlineStatus,showLastActive,showLocation,allowStrangerMessages);

@override
String toString() {
  return 'PrivacyPreferences(showOnlineStatus: $showOnlineStatus, showLastActive: $showLastActive, showLocation: $showLocation, allowStrangerMessages: $allowStrangerMessages)';
}


}

/// @nodoc
abstract mixin class $PrivacyPreferencesCopyWith<$Res>  {
  factory $PrivacyPreferencesCopyWith(PrivacyPreferences value, $Res Function(PrivacyPreferences) _then) = _$PrivacyPreferencesCopyWithImpl;
@useResult
$Res call({
 bool? showOnlineStatus, bool? showLastActive, bool? showLocation, bool? allowStrangerMessages
});




}
/// @nodoc
class _$PrivacyPreferencesCopyWithImpl<$Res>
    implements $PrivacyPreferencesCopyWith<$Res> {
  _$PrivacyPreferencesCopyWithImpl(this._self, this._then);

  final PrivacyPreferences _self;
  final $Res Function(PrivacyPreferences) _then;

/// Create a copy of PrivacyPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showOnlineStatus = freezed,Object? showLastActive = freezed,Object? showLocation = freezed,Object? allowStrangerMessages = freezed,}) {
  return _then(_self.copyWith(
showOnlineStatus: freezed == showOnlineStatus ? _self.showOnlineStatus : showOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool?,showLastActive: freezed == showLastActive ? _self.showLastActive : showLastActive // ignore: cast_nullable_to_non_nullable
as bool?,showLocation: freezed == showLocation ? _self.showLocation : showLocation // ignore: cast_nullable_to_non_nullable
as bool?,allowStrangerMessages: freezed == allowStrangerMessages ? _self.allowStrangerMessages : allowStrangerMessages // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacyPreferences].
extension PrivacyPreferencesPatterns on PrivacyPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacyPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacyPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacyPreferences value)  $default,){
final _that = this;
switch (_that) {
case _PrivacyPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacyPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacyPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? showOnlineStatus,  bool? showLastActive,  bool? showLocation,  bool? allowStrangerMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacyPreferences() when $default != null:
return $default(_that.showOnlineStatus,_that.showLastActive,_that.showLocation,_that.allowStrangerMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? showOnlineStatus,  bool? showLastActive,  bool? showLocation,  bool? allowStrangerMessages)  $default,) {final _that = this;
switch (_that) {
case _PrivacyPreferences():
return $default(_that.showOnlineStatus,_that.showLastActive,_that.showLocation,_that.allowStrangerMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? showOnlineStatus,  bool? showLastActive,  bool? showLocation,  bool? allowStrangerMessages)?  $default,) {final _that = this;
switch (_that) {
case _PrivacyPreferences() when $default != null:
return $default(_that.showOnlineStatus,_that.showLastActive,_that.showLocation,_that.allowStrangerMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivacyPreferences implements PrivacyPreferences {
  const _PrivacyPreferences({this.showOnlineStatus, this.showLastActive, this.showLocation, this.allowStrangerMessages});
  factory _PrivacyPreferences.fromJson(Map<String, dynamic> json) => _$PrivacyPreferencesFromJson(json);

@override final  bool? showOnlineStatus;
@override final  bool? showLastActive;
@override final  bool? showLocation;
@override final  bool? allowStrangerMessages;

/// Create a copy of PrivacyPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacyPreferencesCopyWith<_PrivacyPreferences> get copyWith => __$PrivacyPreferencesCopyWithImpl<_PrivacyPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivacyPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacyPreferences&&(identical(other.showOnlineStatus, showOnlineStatus) || other.showOnlineStatus == showOnlineStatus)&&(identical(other.showLastActive, showLastActive) || other.showLastActive == showLastActive)&&(identical(other.showLocation, showLocation) || other.showLocation == showLocation)&&(identical(other.allowStrangerMessages, allowStrangerMessages) || other.allowStrangerMessages == allowStrangerMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showOnlineStatus,showLastActive,showLocation,allowStrangerMessages);

@override
String toString() {
  return 'PrivacyPreferences(showOnlineStatus: $showOnlineStatus, showLastActive: $showLastActive, showLocation: $showLocation, allowStrangerMessages: $allowStrangerMessages)';
}


}

/// @nodoc
abstract mixin class _$PrivacyPreferencesCopyWith<$Res> implements $PrivacyPreferencesCopyWith<$Res> {
  factory _$PrivacyPreferencesCopyWith(_PrivacyPreferences value, $Res Function(_PrivacyPreferences) _then) = __$PrivacyPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool? showOnlineStatus, bool? showLastActive, bool? showLocation, bool? allowStrangerMessages
});




}
/// @nodoc
class __$PrivacyPreferencesCopyWithImpl<$Res>
    implements _$PrivacyPreferencesCopyWith<$Res> {
  __$PrivacyPreferencesCopyWithImpl(this._self, this._then);

  final _PrivacyPreferences _self;
  final $Res Function(_PrivacyPreferences) _then;

/// Create a copy of PrivacyPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showOnlineStatus = freezed,Object? showLastActive = freezed,Object? showLocation = freezed,Object? allowStrangerMessages = freezed,}) {
  return _then(_PrivacyPreferences(
showOnlineStatus: freezed == showOnlineStatus ? _self.showOnlineStatus : showOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool?,showLastActive: freezed == showLastActive ? _self.showLastActive : showLastActive // ignore: cast_nullable_to_non_nullable
as bool?,showLocation: freezed == showLocation ? _self.showLocation : showLocation // ignore: cast_nullable_to_non_nullable
as bool?,allowStrangerMessages: freezed == allowStrangerMessages ? _self.allowStrangerMessages : allowStrangerMessages // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$UpdateUserPreferencesDto {

 NotificationPreferences? get notifications; PrivacyPreferences? get privacy; Map<String, double>? get feedWeights;
/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserPreferencesDtoCopyWith<UpdateUserPreferencesDto> get copyWith => _$UpdateUserPreferencesDtoCopyWithImpl<UpdateUserPreferencesDto>(this as UpdateUserPreferencesDto, _$identity);

  /// Serializes this UpdateUserPreferencesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserPreferencesDto&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&const DeepCollectionEquality().equals(other.feedWeights, feedWeights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notifications,privacy,const DeepCollectionEquality().hash(feedWeights));

@override
String toString() {
  return 'UpdateUserPreferencesDto(notifications: $notifications, privacy: $privacy, feedWeights: $feedWeights)';
}


}

/// @nodoc
abstract mixin class $UpdateUserPreferencesDtoCopyWith<$Res>  {
  factory $UpdateUserPreferencesDtoCopyWith(UpdateUserPreferencesDto value, $Res Function(UpdateUserPreferencesDto) _then) = _$UpdateUserPreferencesDtoCopyWithImpl;
@useResult
$Res call({
 NotificationPreferences? notifications, PrivacyPreferences? privacy, Map<String, double>? feedWeights
});


$NotificationPreferencesCopyWith<$Res>? get notifications;$PrivacyPreferencesCopyWith<$Res>? get privacy;

}
/// @nodoc
class _$UpdateUserPreferencesDtoCopyWithImpl<$Res>
    implements $UpdateUserPreferencesDtoCopyWith<$Res> {
  _$UpdateUserPreferencesDtoCopyWithImpl(this._self, this._then);

  final UpdateUserPreferencesDto _self;
  final $Res Function(UpdateUserPreferencesDto) _then;

/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notifications = freezed,Object? privacy = freezed,Object? feedWeights = freezed,}) {
  return _then(_self.copyWith(
notifications: freezed == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as NotificationPreferences?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as PrivacyPreferences?,feedWeights: freezed == feedWeights ? _self.feedWeights : feedWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}
/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res>? get notifications {
    if (_self.notifications == null) {
    return null;
  }

  return $NotificationPreferencesCopyWith<$Res>(_self.notifications!, (value) {
    return _then(_self.copyWith(notifications: value));
  });
}/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivacyPreferencesCopyWith<$Res>? get privacy {
    if (_self.privacy == null) {
    return null;
  }

  return $PrivacyPreferencesCopyWith<$Res>(_self.privacy!, (value) {
    return _then(_self.copyWith(privacy: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateUserPreferencesDto].
extension UpdateUserPreferencesDtoPatterns on UpdateUserPreferencesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserPreferencesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserPreferencesDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserPreferencesDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationPreferences? notifications,  PrivacyPreferences? privacy,  Map<String, double>? feedWeights)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto() when $default != null:
return $default(_that.notifications,_that.privacy,_that.feedWeights);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationPreferences? notifications,  PrivacyPreferences? privacy,  Map<String, double>? feedWeights)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto():
return $default(_that.notifications,_that.privacy,_that.feedWeights);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationPreferences? notifications,  PrivacyPreferences? privacy,  Map<String, double>? feedWeights)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserPreferencesDto() when $default != null:
return $default(_that.notifications,_that.privacy,_that.feedWeights);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserPreferencesDto implements UpdateUserPreferencesDto {
  const _UpdateUserPreferencesDto({this.notifications, this.privacy, final  Map<String, double>? feedWeights}): _feedWeights = feedWeights;
  factory _UpdateUserPreferencesDto.fromJson(Map<String, dynamic> json) => _$UpdateUserPreferencesDtoFromJson(json);

@override final  NotificationPreferences? notifications;
@override final  PrivacyPreferences? privacy;
 final  Map<String, double>? _feedWeights;
@override Map<String, double>? get feedWeights {
  final value = _feedWeights;
  if (value == null) return null;
  if (_feedWeights is EqualUnmodifiableMapView) return _feedWeights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserPreferencesDtoCopyWith<_UpdateUserPreferencesDto> get copyWith => __$UpdateUserPreferencesDtoCopyWithImpl<_UpdateUserPreferencesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserPreferencesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserPreferencesDto&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&const DeepCollectionEquality().equals(other._feedWeights, _feedWeights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notifications,privacy,const DeepCollectionEquality().hash(_feedWeights));

@override
String toString() {
  return 'UpdateUserPreferencesDto(notifications: $notifications, privacy: $privacy, feedWeights: $feedWeights)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserPreferencesDtoCopyWith<$Res> implements $UpdateUserPreferencesDtoCopyWith<$Res> {
  factory _$UpdateUserPreferencesDtoCopyWith(_UpdateUserPreferencesDto value, $Res Function(_UpdateUserPreferencesDto) _then) = __$UpdateUserPreferencesDtoCopyWithImpl;
@override @useResult
$Res call({
 NotificationPreferences? notifications, PrivacyPreferences? privacy, Map<String, double>? feedWeights
});


@override $NotificationPreferencesCopyWith<$Res>? get notifications;@override $PrivacyPreferencesCopyWith<$Res>? get privacy;

}
/// @nodoc
class __$UpdateUserPreferencesDtoCopyWithImpl<$Res>
    implements _$UpdateUserPreferencesDtoCopyWith<$Res> {
  __$UpdateUserPreferencesDtoCopyWithImpl(this._self, this._then);

  final _UpdateUserPreferencesDto _self;
  final $Res Function(_UpdateUserPreferencesDto) _then;

/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notifications = freezed,Object? privacy = freezed,Object? feedWeights = freezed,}) {
  return _then(_UpdateUserPreferencesDto(
notifications: freezed == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as NotificationPreferences?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as PrivacyPreferences?,feedWeights: freezed == feedWeights ? _self._feedWeights : feedWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}

/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res>? get notifications {
    if (_self.notifications == null) {
    return null;
  }

  return $NotificationPreferencesCopyWith<$Res>(_self.notifications!, (value) {
    return _then(_self.copyWith(notifications: value));
  });
}/// Create a copy of UpdateUserPreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivacyPreferencesCopyWith<$Res>? get privacy {
    if (_self.privacy == null) {
    return null;
  }

  return $PrivacyPreferencesCopyWith<$Res>(_self.privacy!, (value) {
    return _then(_self.copyWith(privacy: value));
  });
}
}

// dart format on
