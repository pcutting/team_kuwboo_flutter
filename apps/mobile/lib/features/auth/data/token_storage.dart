import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_models.dart';

/// Persists auth tokens + minimal user identity in the platform keychain
/// (iOS Keychain / Android EncryptedSharedPreferences).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserPhone = 'user_phone';
  static const _kUserEmail = 'user_email';
  static const _kUserAvatar = 'user_avatar';

  Future<void> writeTokens(AuthTokens tokens) async {
    await _storage.write(key: _kAccessToken, value: tokens.accessToken);
    await _storage.write(key: _kRefreshToken, value: tokens.refreshToken);
  }

  Future<void> writeUser(AuthUser user) async {
    await _storage.write(key: _kUserId, value: user.id);
    await _storage.write(key: _kUserName, value: user.name);
    await _storage.write(key: _kUserPhone, value: user.phone);
    await _storage.write(key: _kUserEmail, value: user.email);
    await _storage.write(key: _kUserAvatar, value: user.avatarUrl);
  }

  Future<AuthTokens?> readTokens() async {
    final a = await _storage.read(key: _kAccessToken);
    final r = await _storage.read(key: _kRefreshToken);
    if (a == null || r == null) return null;
    return AuthTokens(accessToken: a, refreshToken: r);
  }

  Future<AuthUser?> readUser() async {
    final id = await _storage.read(key: _kUserId);
    if (id == null) return null;
    return AuthUser(
      id: id,
      name: await _storage.read(key: _kUserName) ?? '',
      phone: await _storage.read(key: _kUserPhone),
      email: await _storage.read(key: _kUserEmail),
      avatarUrl: await _storage.read(key: _kUserAvatar),
    );
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() =>
      _storage.read(key: _kRefreshToken);

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserName);
    await _storage.delete(key: _kUserPhone);
    await _storage.delete(key: _kUserEmail);
    await _storage.delete(key: _kUserAvatar);
  }
}
