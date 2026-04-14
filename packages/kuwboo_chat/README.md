# kuwboo_chat

Canonical chat module for Kuwboo: one inbox, one conversation screen, and a
shared conversation-card atom. All features (YoYo, Dating, Shop, …) consume
the same screens with a `moduleKey` discriminator.

**Status:** active

## Public API

Top-level exports from `lib/kuwboo_chat.dart`:

- `ChatInboxScreen` — module-filtered inbox
- `ChatConversationScreen` — single-thread view
- `ProtoConversationCard` — shared list-tile atom
- Chat ornaments (badges, presence dots, etc.)

## Workspace dependencies

- `kuwboo_shell`, `kuwboo_models`, `kuwboo_api_client`

Consumed by: `kuwboo_screens`, `apps/mobile`, `apps/web`.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:kuwboo_chat/kuwboo_chat.dart';

// Inside a router:
// GoRoute(path: '/chat', builder: (_, __) => const ChatInboxScreen());
```
