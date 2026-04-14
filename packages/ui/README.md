# kuwboo_ui

Shared Kuwboo UI widget components that are independent of the shell.

**Status:** active (thin — theme/colors/icons now live in `kuwboo_shell`)

## Public API

`lib/kuwboo_ui.dart` is currently a library marker; theme, color palettes,
and icon sets have moved to `package:kuwboo_shell`.
Import `package:kuwboo_shell/kuwboo_shell.dart` for `ProtoTheme`,
`ColorPalette`, and `ProtoIconSet`.

## Workspace dependencies

None.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:kuwboo_ui/kuwboo_ui.dart'; // library marker
```
