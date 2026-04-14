# kuwboo_screens

Feature screens for every Kuwboo service: YoYo, Video, Dating, Social, Shop,
Profile, Sponsored. Consumed by both mobile and web apps through a shared
`ProtoScaffold`.

**Status:** active

## Public API

Top-level exports from `lib/kuwboo_screens.dart` — grouped by feature folder:

- **YoYo:** nearby, connect, wave, settings, filter sheet, user profile
- **Video:** feed, comments, recording, edit, creator profile, discover, sound
- **Dating:** card stack, expanded profile, filters, likes, match overlay, matches list
- **Social:** feed, stumble, composer, story viewer, friends list, events
- **Shop / Profile / Sponsored** — see the barrel file for the full list

## Workspace dependencies

- `kuwboo_shell`, `kuwboo_chat`, `kuwboo_models`

Consumed by: `apps/mobile`, `apps/web`.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:kuwboo_screens/kuwboo_screens.dart';

// GoRoute(path: '/yoyo/nearby', builder: (_, __) => const YoyoNearbyScreen());
```
