import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_provider.dart';
import 'auth_provider.dart';

/// Shared [DevicesApi] for push-token registration.
final devicesApiProvider = Provider<DevicesApi>(
  (ref) => DevicesApi(ref.watch(apiClientProvider)),
);

/// Firebase Messaging handle.
final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

/// Request push permissions + register the FCM token with the backend.
///
/// Call once after successful authentication. Idempotent — re-registering
/// with the same token is a server-side upsert. Call [deactivateDevice]
/// on logout.
Future<void> registerForPush(Ref ref) async {
  final auth = ref.read(authProvider);
  if (!auth.isAuthenticated) return;

  final messaging = ref.read(firebaseMessagingProvider);

  // iOS: ask for notification permission. Android grants by default
  // pre-Android-13; post-13 also prompts via this call.
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  if (token == null) return;

  final platform = Platform.isIOS
      ? DevicePlatform.ios
      : Platform.isAndroid
          ? DevicePlatform.android
          : DevicePlatform.web;

  try {
    await ref.read(devicesApiProvider).register(
          RegisterDeviceDto(
            fcmToken: token,
            platform: platform,
          ),
        );
  } catch (_) {
    // Non-fatal: push notifications will simply not arrive until the
    // next registration attempt succeeds.
  }

  // Re-register if the token rotates (FCM may rotate periodically).
  messaging.onTokenRefresh.listen((newToken) {
    unawaited(
      ref
          .read(devicesApiProvider)
          .register(RegisterDeviceDto(fcmToken: newToken, platform: platform)),
    );
  });
}

/// Call on logout to deactivate this device server-side (stops push).
Future<void> deactivateDevice(Ref ref) async {
  final messaging = ref.read(firebaseMessagingProvider);
  final token = await messaging.getToken();
  if (token == null) return;
  try {
    await ref.read(devicesApiProvider).deactivate(token);
  } catch (_) {
    // Best-effort.
  }
}
