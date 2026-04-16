import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'providers/package_overrides.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught Flutter errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass uncaught async errors to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Bridge every `throw UnimplementedError` provider declared across the
  // shared packages (kuwboo_screens, kuwboo_chat) onto the real mobile
  // `apiClientProvider`. See `providers/package_overrides.dart` for the
  // full list and the rationale behind each entry.
  final overrides = buildPackageOverrides();

  if (kDebugMode) {
    // Fail loudly at startup if a new `throw UnimplementedError` provider
    // landed in a shared package without a matching override here.
    final probe = ProviderContainer(overrides: overrides);
    try {
      assertNoUnoverriddenPackageProviders(probe);
    } finally {
      probe.dispose();
    }
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const KuwbooApp(),
    ),
  );
}
