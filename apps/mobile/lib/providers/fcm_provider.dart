import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

DevicePlatform _currentDevicePlatform() {
  if (Platform.isIOS) return DevicePlatform.ios;
  if (Platform.isAndroid) return DevicePlatform.android;
  return DevicePlatform.web;
}

/// Request push permissions + register the FCM token with the backend.
///
/// Call once after successful authentication. Idempotent — re-registering
/// with the same token is a server-side upsert. Call [deactivateDevice]
/// on logout.
///
/// The long-lived [FirebaseMessaging.onTokenRefresh] subscription is owned
/// by [fcmTokenListenerProvider]; this function handles the initial
/// permission prompt + first registration and then makes sure the listener
/// is instantiated.
Future<void> registerForPush(Ref ref) async {
  final auth = ref.read(authProvider);
  if (!auth.isAuthenticated) return;

  final messaging = ref.read(firebaseMessagingProvider);

  // iOS: ask for notification permission. Android grants by default
  // pre-Android-13; post-13 also prompts via this call.
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  if (token == null) {
    debugPrint('[fcm] getToken returned null; skipping registration');
    return;
  }

  final platform = _currentDevicePlatform();

  try {
    await ref.read(devicesApiProvider).register(
          RegisterDeviceDto(fcmToken: token, platform: platform),
        );
    debugPrint('[fcm] device registered');
  } catch (error, stack) {
    // Non-fatal: push notifications will simply not arrive until the
    // next registration attempt succeeds. Surface to Crashlytics so the
    // silent-failure mode that shipped to the first TestFlight build
    // never recurs without a breadcrumb.
    debugPrint('[fcm] device register failed');
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'kuwboo fcm',
      context: ErrorDescription('registering FCM token with backend'),
    ));
  }

  // Reading the provider instantiates a single long-lived subscription
  // tied to the ProviderContainer lifecycle. Hot-reload and repeated
  // registerForPush calls cannot stack duplicate listeners.
  ref.read(fcmTokenListenerProvider);
}

/// Call on logout to deactivate this device server-side (stops push).
Future<void> deactivateDevice(Ref ref) async {
  final messaging = ref.read(firebaseMessagingProvider);
  final token = await messaging.getToken();
  if (token == null) return;
  try {
    await ref.read(devicesApiProvider).deactivate(token);
    debugPrint('[fcm] device deactivated');
  } catch (error) {
    // Best-effort: the server will eventually GC stale tokens.
    debugPrint('[fcm] device deactivate failed');
  }
}

/// Long-lived [FirebaseMessaging.onTokenRefresh] listener.
///
/// Created once per [ProviderContainer]. Rotating FCM tokens are
/// re-registered with the backend so push delivery survives token churn.
/// The subscription is cancelled via [Ref.onDispose] when the provider is
/// disposed — either because nobody is watching it anymore, or because the
/// app tears down.
///
/// Errors surface via [debugPrint] and [FlutterError.reportError] rather
/// than being silently swallowed, which made debugging dead push delivery
/// nearly impossible under the previous function-scoped listener.
final fcmTokenListenerProvider = Provider<StreamSubscription<String>>((ref) {
  final messaging = ref.read(firebaseMessagingProvider);
  final platform = _currentDevicePlatform();

  Future<void> reregister(String token) async {
    try {
      await ref.read(devicesApiProvider).register(
            RegisterDeviceDto(fcmToken: token, platform: platform),
          );
      debugPrint('[fcm] token refresh re-register succeeded');
    } catch (error, stack) {
      debugPrint('[fcm] re-register after refresh failed');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'kuwboo fcm',
        context: ErrorDescription('re-registering FCM token after refresh'),
      ));
    }
  }

  final subscription = messaging.onTokenRefresh.listen(
    (newToken) {
      debugPrint('[fcm] token refreshed; re-registering');
      unawaited(reregister(newToken));
    },
    onError: (Object error, StackTrace stack) {
      debugPrint('[fcm] onTokenRefresh stream error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'kuwboo fcm',
        context: ErrorDescription('FCM onTokenRefresh stream'),
      ));
    },
  );
  ref.onDispose(subscription.cancel);
  return subscription;
});

/// Wires [registerForPush] / [deactivateDevice] to auth-state edge
/// transitions.
///
/// Instantiate once from the app root by reading this provider — it
/// listens to [authProvider] internally and fires on sign-in / sign-out.
/// Idempotent across rebuilds: the provider caches a single subscription
/// whose lifecycle is tied to the [ProviderContainer].
final fcmLifecycleListenerProvider = Provider<ProviderSubscription<AuthState>>(
  (ref) {
    AuthState? previous;
    final subscription = ref.listen<AuthState>(
      authProvider,
      (prev, next) {
        final wasAuthed = (prev ?? previous)?.isAuthenticated ?? false;
        final isAuthed = next.isAuthenticated;
        if (!wasAuthed && isAuthed) {
          unawaited(registerForPush(ref));
        } else if (wasAuthed && !isAuthed) {
          unawaited(deactivateDevice(ref));
        }
        previous = next;
      },
      fireImmediately: true,
    );
    ref.onDispose(subscription.close);
    return subscription;
  },
);
