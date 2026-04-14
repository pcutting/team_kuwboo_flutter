# kuwboo_auth

Authentication flow screens for Kuwboo — welcome, onboarding, tutorial,
method picker, signup, login, phone, OTP, birthday, profile setup, and
age-block. Extracted from `kuwboo_screens` so auth can iterate
independently as the backend auth module lands.

**Status:** active

## Public API

Top-level exports from `lib/kuwboo_auth.dart`:

- `AuthWelcomeScreen`
- `AuthOnboardingScreen`
- `AuthTutorialScreen`
- `AuthMethodScreen`
- `AuthSignupScreen`
- `AuthLoginScreen`
- `AuthPhoneScreen`
- `AuthOtpScreen`
- `AuthBirthdayScreen`
- `AuthProfileScreen`
- `AuthAgeBlockScreen`

## Workspace dependencies

- `kuwboo_shell`, `kuwboo_models`, `kuwboo_api_client`

Consumed by: `apps/mobile`, `apps/web`.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:kuwboo_auth/kuwboo_auth.dart';

// Inside a router:
// GoRoute(path: '/auth/welcome', builder: (_, __) => const AuthWelcomeScreen());
```
