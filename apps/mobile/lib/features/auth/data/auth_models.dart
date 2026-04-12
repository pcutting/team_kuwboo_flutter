/// Tokens returned from the `/auth/phone/verify-otp`, `/auth/refresh`,
/// and social-login endpoints.
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

/// Slim user shape. The backend returns the full `User` entity — we only
/// extract the fields the mobile client currently needs.
class AuthUser {
  final String id;
  final String? phone;
  final String? email;
  final String name;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );

  AuthUser copyWith({String? name, String? avatarUrl}) => AuthUser(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

/// Full response body for verify-otp and social login.
class AuthResponse {
  final AuthTokens tokens;
  final AuthUser user;
  final bool isNewUser;

  const AuthResponse({
    required this.tokens,
    required this.user,
    required this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        tokens: AuthTokens.fromJson(json),
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        isNewUser: (json['isNewUser'] as bool?) ?? false,
      );
}
