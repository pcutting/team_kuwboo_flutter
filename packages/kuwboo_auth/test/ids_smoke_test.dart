import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Finder that matches the [Semantics] widget element with the given
/// identifier. We use this in preference to `find.bySemanticsIdentifier`
/// (which queries the rendered semantics tree) because the auth flow's
/// `TabBarView` + `IntlPhoneField` + `Spacer` combination hits a layout
/// path where some `Semantics` annotations don't end up as their own
/// `SemanticsNode` in the rendered tree (Flutter 3.35) — yet the widget
/// is in the widget tree and its `Semantics.properties` correctly
/// describe what state would be exposed at runtime.
///
/// This is the same trade-off Maestro encounters at runtime against a
/// real device: it queries the platform accessibility tree, which is
/// derived from the widget-side `SemanticsConfiguration`, not from
/// Flutter's debug semantics. Asserting on the widget's properties is
/// the stable equivalent in unit tests.
Finder _bySemId(String id) {
  return find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.identifier == id,
    description: 'Semantics widget with identifier "$id"',
  );
}

/// Returns the [SemanticsProperties] for the (single) [Semantics] widget
/// with the given identifier. Throws if zero or multiple are found.
SemanticsProperties _props(WidgetTester tester, String id) {
  final matches = _bySemId(id).evaluate().toList();
  if (matches.isEmpty) {
    throw StateError('No Semantics widget with identifier "$id" in the tree.');
  }
  if (matches.length > 1) {
    throw StateError(
        'Multiple (${matches.length}) Semantics widgets with identifier "$id"');
  }
  return (matches.first.widget as Semantics).properties;
}

/// Wraps an auth screen in the minimum scaffolding it expects:
/// ProviderScope (Riverpod), ProtoThemeProvider, ProtoStateAccess (legacy
/// InheritedWidget bridge that ProtoSubBar / ProtoTopBar require), and a
/// MaterialApp with a Material host. Auth screens use `context.go(...)`
/// for post-action navigation; we don't drive that in these tests because
/// we only care about ID presence + state flag behaviour.
Widget _host(Widget child) {
  return ProviderScope(
    child: Consumer(
      builder: (context, ref, _) {
        final shell = ref.watch(shellStateProvider);
        final yoyo = ref.watch(yoyoStateProvider);
        final shellNotifier = ref.read(shellStateProvider.notifier);
        final yoyoNotifier = ref.read(yoyoStateProvider.notifier);
        return ProtoThemeProvider(
          theme: ProtoTheme.v0UrbanWarmth(),
          child: ProtoStateAccess(
            shell: shell,
            yoyo: yoyo,
            shellNotifier: shellNotifier,
            yoyoNotifier: yoyoNotifier,
            child: MaterialApp(
              home: Material(child: child),
            ),
          ),
        );
      },
    ),
  );
}

/// Pumps a child at a phone-shaped surface (390x844, iPhone 15 Pro logical
/// size). The default 800x600 test surface is landscape and overflows our
/// portrait-designed auth screens. Note: we don't enable semantics —
/// these tests query the *widget* tree (via `find.byWidgetPredicate`)
/// rather than the rendered semantics tree, so `ensureSemantics()` would
/// just be dead weight that tearDown has to clean up.
Future<void> _pumpAtPhoneSize(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_host(child));
  await tester.pumpAndSettle();
}

void main() {
  group('AuthIds constants', () {
    test('otpDigit interpolates index', () {
      expect(AuthIds.otpDigit(0), 'auth.otp.digit_0');
      expect(AuthIds.otpDigit(5), 'auth.otp.digit_5');
    });

    test('tutorialDot interpolates index', () {
      expect(AuthIds.tutorialDot(0), 'auth.tutorial.dot_0');
      expect(AuthIds.tutorialDot(3), 'auth.tutorial.dot_3');
    });

    test('phone send_code is the value Maestro flows expect', () {
      expect(AuthIds.phoneSendCode, 'auth.phone.send_code');
    });
  });

  group('AuthPhoneScreen smoke', () {
    testWidgets(
      'renders all phone-tab IDs (tabs, field, header, send_code)',
      (tester) async {
        await _pumpAtPhoneSize(tester, const AuthPhoneScreen());

        expect(_bySemId(AuthIds.phoneTabPhone), findsOneWidget);
        expect(_bySemId(AuthIds.phoneTabEmail), findsOneWidget);
        expect(_bySemId(AuthIds.phoneField), findsOneWidget);
        expect(_bySemId(AuthIds.phoneHeaderLabel), findsOneWidget);
        expect(_bySemId(AuthIds.phoneSendCode), findsOneWidget);
      },
    );
  });

  group('AuthPhoneScreen send-code state', () {
    testWidgets('Send Code starts disabled with no digits typed',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthPhoneScreen());

      final props = _props(tester, AuthIds.phoneSendCode);
      expect(
        props.enabled,
        isFalse,
        reason: 'Send Code must be disabled before any digits are typed',
      );
    });

    testWidgets('Send Code becomes enabled once 10 digits are entered',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthPhoneScreen());

      // IntlPhoneField wraps a TextField — the only TextField on the
      // active phone tab is the phone number input. Type into it.
      final phoneField = find.byType(TextField);
      expect(phoneField, findsOneWidget);

      await tester.enterText(phoneField, '6143002053');
      await tester.pumpAndSettle();

      final props = _props(tester, AuthIds.phoneSendCode);
      expect(
        props.enabled,
        isTrue,
        reason: 'Send Code must enable after 10-digit entry',
      );
    });

    testWidgets(
      'tap Email tab → email tab is selected, phone tab is not',
      (tester) async {
        await _pumpAtPhoneSize(tester, const AuthPhoneScreen());

        // Both tab pills carry visible "Phone" / "Email" Text. Tap on
        // the Email visible label — the wrapping GestureDetector still
        // dispatches the tap.
        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();

        final emailProps = _props(tester, AuthIds.phoneTabEmail);
        final phoneProps = _props(tester, AuthIds.phoneTabPhone);

        expect(
          emailProps.selected,
          isTrue,
          reason: 'email tab should carry selected:true after tap',
        );
        expect(
          phoneProps.selected,
          isFalse,
          reason: 'phone tab must lose selected:true when email tab is active',
        );
      },
    );
  });

  group('AuthOtpScreen state', () {
    testWidgets('digit_0 carries the typed value', (tester) async {
      // Slightly wider surface than the iPhone-15-Pro logical 390 to
      // give 6 OTP boxes (48px each + 5px padding either side) room
      // to fit without a 6-pixel horizontal overflow assertion.
      await tester.binding.setSurfaceSize(const Size(414, 896));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_host(
        const AuthOtpScreen(
          args: AuthOtpArgs(
            identifier: '+15551234567',
            channel: AuthOtpChannel.phone,
          ),
        ),
      ));
      // OTP screen kicks off a 30-second resend countdown via a chained
      // `Future.delayed` loop in initState. pumpAndSettle would block on
      // it forever. Pump enough virtual time (31 × 1s) to drain the
      // chain so tearDown doesn't see a pending timer.
      await tester.pump();

      // Six digit boxes — type into the first.
      final boxes = find.byType(TextField);
      expect(boxes, findsNWidgets(6));

      await tester.enterText(boxes.first, '1');
      await tester.pump();

      final props = _props(tester, AuthIds.otpDigit(0));
      expect(
        props.value,
        '1',
        reason: 'OTP digit semantics value should reflect controller text',
      );

      // Drain the resend countdown so the framework's "no pending
      // timers at end of test" invariant passes. Each tick is a 1s
      // Future.delayed; 31 pumps takes us past the 30 → _canResend
      // transition where the doWhile loop exits.
      for (var i = 0; i < 31; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    });
  });

  group('AuthBirthdayScreen smoke', () {
    testWidgets('wheel_year semantics widget has a non-empty value',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthBirthdayScreen());

      final props = _props(tester, AuthIds.birthdayWheelYear);
      expect(
        props.value,
        isNotNull,
        reason: 'year wheel must expose its current selection as a value',
      );
      expect(
        (props.value ?? '').isNotEmpty,
        isTrue,
        reason: 'year wheel value should be a non-empty string',
      );
    });
  });

  group('AuthProfileScreen state', () {
    testWidgets(
      'invalid username raises liveRegion on the username error text',
      (tester) async {
        await _pumpAtPhoneSize(tester, const AuthProfileScreen());

        // Two TextFields on this screen: display name (first) and
        // username (second).
        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(2));

        // Username must match `^[a-zA-Z0-9_]{3,20}$`. A 2-char value is
        // allowed by the input formatter but rejected by the validator,
        // which sets _usernameError and triggers the liveRegion flag.
        await tester.enterText(fields.at(1), 'ab');
        await tester.pumpAndSettle();

        final props = _props(tester, AuthIds.profileUsernameError);
        expect(
          props.liveRegion,
          isTrue,
          reason:
              'username error text must announce as a live region when validation fails',
        );
      },
    );
  });

  group('AuthTutorialScreen smoke', () {
    testWidgets('dot_0 selected, dot_1 not selected on initial render',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthTutorialScreen());

      final firstDot = _props(tester, AuthIds.tutorialDot(0));
      final secondDot = _props(tester, AuthIds.tutorialDot(1));

      expect(
        firstDot.selected,
        isTrue,
        reason: 'first tutorial dot should be selected on initial render',
      );
      expect(
        secondDot.selected,
        isFalse,
        reason: 'subsequent tutorial dots should not be selected initially',
      );
    });
  });
}
