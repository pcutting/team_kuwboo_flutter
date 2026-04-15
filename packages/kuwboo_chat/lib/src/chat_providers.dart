import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Host-app provides this override via `ProviderScope(overrides: [...])`.
///
/// NOTE: this name is shared across feature modules (auth, feed, chat, etc.)
/// by convention — the coordinator deduplicates at merge time. The host app
/// supplies a single concrete `KuwbooApiClient` for all modules.
final apiClientProvider = Provider<KuwbooApiClient>((ref) {
  throw UnimplementedError(
    'apiClientProvider must be overridden at the ProviderScope root '
    'with a concrete KuwbooApiClient instance.',
  );
});

/// Messaging API derived from the shared [apiClientProvider].
final messagingApiProvider = Provider<MessagingApi>((ref) {
  return MessagingApi(ref.watch(apiClientProvider));
});

/// All threads for the current user.
///
/// Backend does not accept a `moduleKey` filter param — per-module filtering
/// is done client-side in the inbox screen.
final threadsProvider = FutureProvider<ThreadListResponse>((ref) async {
  return ref.watch(messagingApiProvider).listThreads();
});

/// Paginated messages for a single thread, keyed by threadId.
///
/// Returns the first page (most recent). Pull-to-refresh invalidates.
/// Socket.io live updates land in Phase 8.
final messagesProvider =
    FutureProvider.family<MessageListResponse, String>((ref, threadId) async {
  return ref.watch(messagingApiProvider).listMessages(threadId);
});
