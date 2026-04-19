import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key used to persist the locally-picked avatar across page reloads.
/// Small images only — we cap at ~1 MB encoded to avoid exhausting
/// localStorage on web (which backs flutter_secure_storage there).
const _kLocalAvatarKey = 'kuwboo_local_avatar_b64';
const _kMaxBase64Length = 1 * 1024 * 1024; // ~750 KB raw → ~1 MB base64

/// Holds the in-session override for the signed-in user's avatar: raw
/// bytes picked during registration (`auth_profile_screen`) or later via
/// the settings "Choose photo" sheet. Any widget rendering the user's
/// avatar (e.g. `ProfileMyScreen`, `ProtoTopBar`) should prefer these
/// bytes over the backend `avatarUrl` when both are present.
///
/// Persists to `flutter_secure_storage` (localStorage on web) so a page
/// refresh keeps the picked image visible until the real backend avatar
/// upload endpoint exists to sync a server-side URL.
class LocalAvatarNotifier extends StateNotifier<Uint8List?> {
  LocalAvatarNotifier({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(null) {
    // Best-effort hydrate; if storage isn't available we just start empty.
    _hydrate();
  }

  final FlutterSecureStorage _storage;

  Future<void> _hydrate() async {
    try {
      final b64 = await _storage.read(key: _kLocalAvatarKey);
      if (b64 == null || b64.isEmpty) return;
      state = base64Decode(b64);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[local avatar] hydrate failed: $e\n$st');
      }
    }
  }

  /// Replace the avatar with freshly-picked bytes and persist.
  Future<void> set(Uint8List bytes) async {
    state = bytes;
    try {
      final encoded = base64Encode(bytes);
      if (encoded.length > _kMaxBase64Length) {
        // Too big to persist; keep in-memory only.
        if (kDebugMode) {
          debugPrint(
            '[local avatar] bytes too large to persist '
            '(${encoded.length} > $_kMaxBase64Length)',
          );
        }
        return;
      }
      await _storage.write(key: _kLocalAvatarKey, value: encoded);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[local avatar] persist failed: $e\n$st');
      }
    }
  }

  /// Clear the avatar (used by the "Remove photo" action).
  Future<void> clear() async {
    state = null;
    try {
      await _storage.delete(key: _kLocalAvatarKey);
    } catch (_) {}
  }
}

/// Read the locally-overridden avatar bytes. Null means "use whatever the
/// backend has".
final localAvatarProvider =
    StateNotifierProvider<LocalAvatarNotifier, Uint8List?>(
      (ref) => LocalAvatarNotifier(),
    );
