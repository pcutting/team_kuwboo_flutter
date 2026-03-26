import 'dart:js_interop';

@JS('_kuwboo.toggleFullscreen')
external JSBoolean _jsToggleFullscreen();

@JS('_kuwboo.isFullscreen')
external JSBoolean _jsIsFullscreen();

@JS('_kuwboo.canInstall')
external JSBoolean _jsCanInstall();

@JS('_kuwboo.triggerInstall')
external JSBoolean _jsTriggerInstall();

@JS('_kuwboo.isIOS')
external JSBoolean _jsIsIOS();

@JS('_kuwboo.isStandalone')
external JSBoolean _jsIsStandalone();

/// Toggle browser fullscreen mode. Returns true if now fullscreen.
bool toggleFullscreen() => _jsToggleFullscreen().toDart;

/// Whether the browser is currently in fullscreen mode.
bool get isFullscreen => _jsIsFullscreen().toDart;

/// Whether a deferred PWA install prompt is available (Android/desktop Chrome).
bool get canInstall => _jsCanInstall().toDart;

/// Trigger the native PWA install prompt. Returns true if triggered.
bool triggerInstall() => _jsTriggerInstall().toDart;

/// Whether the device is iOS (no programmatic install prompt available).
bool get isIOS => _jsIsIOS().toDart;

/// Whether the app is running in standalone/PWA mode (already installed).
bool get isStandalone => _jsIsStandalone().toDart;

@JS('_kuwboo.isMobile')
external JSBoolean _jsIsMobile();

/// Whether the device is a phone (iOS or Android). Fullscreen API doesn't
/// work reliably on phones — use PWA install instead.
bool get isMobile => _jsIsMobile().toDart;

@JS('_kuwboo.hasUpdate')
external JSBoolean _jsHasUpdate();

@JS('_kuwboo.applyUpdate')
external void _jsApplyUpdate();

/// Whether a new service worker version is waiting to activate.
bool get hasUpdate => _jsHasUpdate().toDart;

/// Reload the page to activate the new service worker version.
void applyUpdate() => _jsApplyUpdate();
