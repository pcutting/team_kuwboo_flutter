import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart' as screens;

import 'app/app.dart';
import 'firebase_options.dart';
import 'providers/api_provider.dart';

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

  runApp(
    ProviderScope(
      overrides: [
        // Bridge kuwboo_screens' package-local `apiClientProvider` (declared
        // with `throw UnimplementedError` so the host app must override it)
        // to the real mobile `apiClientProvider`. Without this, profile
        // screens that depend on `meProvider` / `unreadNotificationCountProvider`
        // crash on first read.
        screens.apiClientProvider.overrideWith(
          (ref) => ref.watch(apiClientProvider),
        ),
      ],
      child: const KuwbooApp(),
    ),
  );
}
