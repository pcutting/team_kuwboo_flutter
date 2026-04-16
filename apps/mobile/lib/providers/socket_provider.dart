import 'package:flutter/foundation.dart';
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

/// Creates a socket.io client for the given namespace.
///
/// Authenticated via the user's current access token in the handshake
/// `auth` payload; the backend's `WsJwtGuard` validates it before allowing
/// the connection. The token is watched via Riverpod, so when auth state
/// changes (login, logout, refresh) the provider is invalidated, the old
/// socket is disposed, and a fresh one is built with the new token on the
/// next read.
///
/// Importantly, when no token is present (cold start, mid-auth-loading,
/// logged out) the socket is built in a disconnected state and `connect()`
/// is never called. Previously we fired `connect()` with an empty
/// `{'token': ''}` payload, the backend silently rejected it, and events
/// never flowed until a full app restart — making "why aren't Waves
/// appearing in the demo" an infuriating heisenbug.
io.Socket _createSocket(Ref ref, String namespace) {
  final token = ref.watch(authProvider.select((s) => s.accessToken));
  final hasToken = token != null && token.isNotEmpty;

  final socket = io.io(
    '${Environment.apiBaseUrl}$namespace',
    io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token ?? ''})
        .build(),
  );

  // Lifecycle logging — surfaces connection state so "nothing happened on
  // the socket" debugging stops being a black box.
  socket.onConnect((_) {
    debugPrint('[socket $namespace] connected');
  });
  socket.onDisconnect((reason) {
    debugPrint('[socket $namespace] disconnected ($reason)');
  });
  socket.onConnectError((error) {
    debugPrint('[socket $namespace] connect error: $error');
  });
  socket.onError((error) {
    debugPrint('[socket $namespace] error: $error');
  });

  if (hasToken) {
    debugPrint('[socket $namespace] connecting with token');
    socket.connect();
  } else {
    // Deliberately leave the socket disconnected. The provider is
    // invalidated as soon as the token materializes (Ref.watch on
    // authProvider's accessToken selector) so we'll rebuild + connect
    // then, rather than fighting a backend auth rejection here.
    debugPrint('[socket $namespace] no token yet; staying disconnected');
  }

  ref.onDispose(() {
    debugPrint('[socket $namespace] provider disposed');
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
