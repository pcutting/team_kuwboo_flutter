# kuwboo_api_client

Dio-based HTTP client for the Kuwboo backend, with an auth interceptor and
token-refresh flow. Tokens are persisted via `flutter_secure_storage`.

**Status:** active (auth/feed surfaces evolving alongside the NestJS backend)

## Public API

Top-level exports from `lib/kuwboo_api_client.dart`:

- `KuwbooApiClient` — Dio wrapper, token storage, response-envelope `unwrap`
- `AuthApi`, `UsersApi`, `ContentApi`, `FeedApi`, `InteractionsApi`,
  `CommentsApi`, `ConnectionsApi`, `MarketplaceApi`, `MessagingApi`, `YoyoApi`

## Workspace dependencies

- `kuwboo_models` (data shapes)

Consumed by: `kuwboo_chat`, `kuwboo_screens`, `apps/mobile`.

## Tests

```sh
flutter test
```

## Example

```dart
import 'package:dio/dio.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

final client = KuwbooApiClient(baseUrl: 'https://api.example.com', dio: Dio());
final auth = AuthApi(client);
await auth.sendOtp(phone: '+15551234567');
```
