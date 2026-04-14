# Inner Circle — Archived

**Status:** Archived 2026-04-14. Pending separate SOW (~$66K), horizon ~1 year.
**Original spec:** [`SPECIFICATION.md`](SPECIFICATION.md)

## Why this exists

Inner Circle is a family-tracking mode (private map, wave pings, location
history per family member) intended as a premium layer on top of the base
YoYo module. It was prototyped as ~1,325 LOC of Flutter UI in
`packages/kuwboo_screens/` + `packages/kuwboo_shell/`, reachable by flipping
`YoyoState.mode` from `0` to `1`.

Because the SOW isn't approved and the horizon is long, keeping the code in
`packages/` was creating cognitive overhead ("what is this, is it live?").
The code was lifted into this archive and removed from the active build.

**Zero backend was ever built for Inner Circle.** The UI drove static demo
data (family members, location pings). Any restoration also needs backend
work per the [spec](SPECIFICATION.md).

## What's here

```
inner_circle_archive/
├── README.md                         ← you are here
├── SPECIFICATION.md                  ← full feature spec (moved from docs/team/internal/)
├── screenshots/
│   └── 01_nearby.png                 ← Inner Circle map view (mode=1) from web prototype
└── source/
    ├── screens/
    │   ├── inner_circle_nearby.dart  ← map + family-member pings (209 LOC)
    │   ├── inner_circle_wave.dart    ← wave/ping flow (209 LOC)
    │   ├── inner_circle_connect.dart ← connect/invite (159 LOC)
    │   └── inner_circle_chat.dart    ← IC messaging view — was orphaned, never routed
    ├── widgets/
    │   └── inner_circle_shared.dart  ← map placeholder, floating card, badges (429 LOC)
    └── state/
        ├── yoyo_state_mode_field.md  ← the removed YoyoState.mode field + callers
        └── demo_family_data.dart     ← DemoLocationPing + DemoFamilyMember + seeds
```

## Restoration recipe

When Neil greenlights Inner Circle:

1. **Find this PR pair** — `git log --all --grep='Inner Circle archive'` pulls up
   the two-PR archive → rip-out sequence from April 2026.

2. **Restore screens**
   ```bash
   cp docs/team/internal/inner_circle_archive/source/screens/*.dart \
      packages/kuwboo_screens/lib/src/yoyo/
   cp docs/team/internal/inner_circle_archive/source/widgets/*.dart \
      packages/kuwboo_screens/lib/src/yoyo/
   ```

3. **Re-export from the barrel** — add the 5 IC files to
   `packages/kuwboo_screens/lib/kuwboo_screens.dart`.

4. **Restore `YoyoState.mode`** — paste the field, `copyWith` entry, and
   `setMode()` from [`source/state/yoyo_state_mode_field.md`](source/state/yoyo_state_mode_field.md)
   into `packages/kuwboo_shell/lib/src/state/proto_state_provider.dart`.

5. **Restore demo data** — paste the three `Demo*` classes and seed lists
   from [`source/state/demo_family_data.dart`](source/state/demo_family_data.dart)
   into `packages/kuwboo_shell/lib/src/data/proto_demo_data.dart`.

6. **Re-add screen branches** — in `yoyo_nearby_screen.dart`,
   `yoyo_wave_screen.dart`, `yoyo_connect_screen.dart`, wrap the build
   method with the `state.yoyoMode == 1 ? InnerCircleXxxView() : ...`
   guard described in the state-fragment notes.

7. **Wire a toggle** — the old `_YoyoModeToggleIcon` in `proto_top_bar.dart`
   was dead code. Build a fresh toggle (settings entry? profile gear?
   premium paywall?) — the design decision was never made.

8. **Build the backend** — the spec calls for family-group entities,
   consent-per-member location-sharing endpoints, and a push pipeline for
   waves. None of this exists. This is the bulk of the SOW.

Rough restoration estimate: **1–2 days** to regain current visual fidelity
(all UI hooks back in), then the spec's worth of backend work after.

## Contract note

Inner Circle is outside the $60K rebuild contract. It's tracked as a
separate ~$66K SOW in `docs/client/CONTRACT_KUWBOO_REBUILD.md` alongside
the main contract. Don't bill Inner Circle hours against the rebuild.
