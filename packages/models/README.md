# kuwboo_models

Shared Kuwboo data models — immutable, JSON-serializable, built with `freezed`.

**Status:** active

## Public API

Top-level exports from `lib/kuwboo_models.dart`:

- `enums.dart` — `Role`, `UserStatus`, `OnlineStatus`, module keys
- `user.dart` — `User`
- `auth.dart` — `AuthResponse`, `TokenPair`
- `content.dart` — `Content` STI hierarchy (video, post, listing, …)
- `comment.dart`, `connection.dart`, `notification_model.dart`
- `feed.dart` — `FeedResponse`
- `product.dart`, `thread.dart`, `auction.dart`, `yoyo.dart`

## Workspace dependencies

None — this package sits at the bottom of the dependency graph.
Consumed by: `kuwboo_api_client`, `kuwboo_chat`, `kuwboo_screens`.

## Tests

```sh
dart test
```

## Example

```dart
import 'package:kuwboo_models/kuwboo_models.dart';

final user = User(id: 'u1', name: 'Jane', createdAt: DateTime.now());
```
