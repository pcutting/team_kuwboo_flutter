# kuwboo_shell

Shared shell infrastructure for Kuwboo: theme, navigation scaffolding, state
providers, and shared UI atoms. Consumed by every feature package.

**Status:** active

## Public API

Top-level exports from `lib/kuwboo_shell.dart`:

- **Theme:** `ProtoTheme`, `ColorPalette`, `ProtoIconSet`, brand colors
- **Shared widgets:** `ProtoScaffold`, `ProtoBottomNav`, `ProtoTopBar`,
  `ProtoDialogs`, `ProtoPressButton`, `ProtoImage`, `ProtoStates`
- **State:** `PrototypeStateProvider`, `ProtoModule`
- **Routes:** `ProtoRoutes`, `ProtoTransitions`
- **Data:** `DemoData`, `ProtoDemoData`

## Workspace dependencies

None (external only: flutter, flutter_riverpod, go_router, icon packs).

Consumed by: `kuwboo_chat`, `kuwboo_screens`, `apps/mobile`, `apps/web`.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:kuwboo_shell/kuwboo_shell.dart';

ProtoScaffold(
  activeModule: ProtoModule.yoyo,
  body: const Placeholder(),
);
```
