# `YoyoState.mode` — archived state contract

Removed from `packages/kuwboo_shell/lib/src/state/proto_state_provider.dart` on
2026-04-14 as part of the Inner Circle archive. Restore these fragments
alongside the IC screens when the SOW is approved.

## Field on `YoyoState`

```dart
// 0 = standard YoYo radar mode, 1 = Inner Circle (family tracking) mode
final int mode;
```

Add to the default constructor:

```dart
this.mode = 0,
```

And to `copyWith`:

```dart
int? mode,
// ...
mode: mode ?? this.mode,
```

## Mutator on `YoyoStateNotifier`

```dart
void setMode(int value) {
  state = state.copyWith(mode: value);
}
```

## Accessor on `ProtoStateAccess`

```dart
int get yoyoMode => yoyo.mode;
```

## Callback on `ProtoStateNotifier`

```dart
void onYoyoModeChanged(int v) => yoyoNotifier.setMode(v);
```

## Top-bar entry point (also deleted)

In `packages/kuwboo_shell/lib/src/shared/proto_top_bar.dart` the
`_YoyoModeToggleIcon` widget class (around line 387) is the UI entry point.
It was never wired into the visible bar — delete it, but save this note so
a fresh implementation can take the same slot.

## Yoyo screen branches

In `packages/kuwboo_screens/lib/src/yoyo/yoyo_nearby_screen.dart`,
`yoyo_wave_screen.dart`, and `yoyo_connect_screen.dart`, each had the shape:

```dart
final state = PrototypeStateProvider.of(context);
if (state.yoyoMode == 1) {
  return const InnerCircleXxxView();
}
// ... existing social/radar UI
```

When restoring, re-wrap the build methods with that same guard.
