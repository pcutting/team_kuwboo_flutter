import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/environment.dart';
import 'auth_provider.dart';

/// Mapping of the three backend WebSocket namespaces to their paths.
class SocketNamespaces {
  const SocketNamespaces._();
  static const chat = '/chat';
  static const proximity = '/proximity';
  static const presence = '/presence';
}

/// Creates a socket.io client for the given namespace. Authenticated via
/// the user's current access token in the handshake `auth` payload; the
/// backend's `WsJwtGuard` validates it before allowing the connection.
///
/// Auto-disposed when no listeners remain. Reconnects are handled by the
/// socket.io client automatically; if the token rotates mid-session the
/// next reconnect will pick up the new value (Ref-watched).
io.Socket _createSocket(Ref ref, String namespace) {
  final token = ref.watch(authProvider.select((s) => s.accessToken));
  final socket = io.io(
    '${Environment.apiBaseUrl}$namespace',
    io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token ?? ''})
        .build(),
  );
  if (token != null) socket.connect();
  ref.onDispose(() {
    socket.dispose();
  });
  return socket;
}

/// Chat namespace socket (`/chat`) — message:send, message:new, thread:join,
/// typing:*, client:state=killed.
final chatSocketProvider = Provider.autoDispose<io.Socket>(
  (ref) => _createSocket(ref, SocketNamespaces.chat),
);

/// Proximity namespace socket (`/proximity`) — location:update,
/// nearby:entered, nearby:left, wave:received.
final proximitySocketProvider = Provider.autoDispose<io.Socket>(
  (ref) => _createSocket(ref, SocketNamespaces.proximity),
);

/// Presence namespace socket (`/presence`) — presence:query, presence:update.
final presenceSocketProvider = Provider.autoDispose<io.Socket>(
  (ref) => _createSocket(ref, SocketNamespaces.presence),
);
