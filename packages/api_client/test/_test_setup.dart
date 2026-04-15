import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub the FlutterSecureStorage platform channel so the auth interceptor
/// can call `getAccessToken()` / `getRefreshToken()` in unit tests without
/// hitting Keychain / EncryptedSharedPreferences.
///
/// Returns `null` for all reads → no Authorization header attached.
void installSecureStorageStub() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'read':
        return null;
      case 'readAll':
        return <String, String>{};
      case 'write':
      case 'delete':
      case 'deleteAll':
      case 'containsKey':
        return null;
    }
    return null;
  });
}
