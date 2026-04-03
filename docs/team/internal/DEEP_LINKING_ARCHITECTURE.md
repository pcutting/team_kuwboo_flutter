# Deep Linking Architecture

> **Status:** Design
> **Author:** Philip Cutting
> **Date:** 2026-03-26
> **Cross-references:**
> - [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — Notification entity (lines 1064-1112), Thread with moduleKey (lines 1392-1410)
> - [REALTIME_ARCHITECTURE.md](./REALTIME_ARCHITECTURE.md) — Notification delivery (Section 8), Socket.io namespaces
> - [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) — COPPA age-gating affects deep link behavior

---

## 1. Problem Statement

Kuwboo needs a unified way to route users to specific content from:
- **Push notifications** (FCM → tap → open correct screen)
- **In-app notifications** (Socket.io event → banner → tap → navigate)
- **Notification inbox** (tap saved notification → navigate)
- **Sharing** (copy link → send to friend → friend opens app at correct screen)
- **Marketing** (email/SMS links → app or web fallback)

The current prototype has no deep linking. The legacy iOS app had partial Firebase Dynamic Links support (`kuwboo://` scheme) but no notification-to-screen routing. The greenfield Flutter app needs this from day one.

---

## 2. URL Scheme Design

### Custom Scheme (In-App Routing)

```
kuwboo://<module>/<screen>/<entityId>?<params>
```

### Universal Links (Sharing, Marketing)

```
https://app.kuwboo.com/<module>/<screen>/<entityId>?<params>
```

Both resolve to the same internal route. Universal links fall back to the web (marketing page or future web app) if the app isn't installed.

### Route Table

| Route Pattern | Screen | Example |
|--------------|--------|---------|
| `kuwboo://video/:videoId` | Video player | `kuwboo://video/abc123` |
| `kuwboo://video/feed` | Video feed (For You) | |
| `kuwboo://shop/product/:productId` | Product detail | `kuwboo://shop/product/def456` |
| `kuwboo://shop/browse` | Shop browse | |
| `kuwboo://chat/inbox` | Chat inbox | |
| `kuwboo://chat/:threadId` | Chat conversation | `kuwboo://chat/thread-789` |
| `kuwboo://chat/:threadId?message=:messageId` | Specific message in chat | `kuwboo://chat/thread-789?message=msg-012` |
| `kuwboo://chat/:threadId?highlight=:cardType` | Transaction card in chat | `kuwboo://chat/thread-789?highlight=offer-456` |
| `kuwboo://dating/profile/:userId` | Dating profile | `kuwboo://dating/profile/user-345` |
| `kuwboo://dating/cards` | Dating swipe cards | |
| `kuwboo://social/post/:postId` | Social post detail | `kuwboo://social/post/post-678` |
| `kuwboo://social/feed` | Social stumble feed | |
| `kuwboo://yoyo/nearby` | YoYo nearby radar | |
| `kuwboo://yoyo/event/:eventId` | YoYo event detail | |
| `kuwboo://profile/:userId` | User profile | `kuwboo://profile/user-345` |
| `kuwboo://profile/me` | Own profile | |
| `kuwboo://notifications` | Notification inbox | |
| `kuwboo://notifications/:notificationId` | Navigate to notification's target | Auto-redirects based on `data.deepLink` |

### Module Mapping

Routes map to the app's `moduleKey` architecture:

| URL Prefix | ModuleScope | Bottom Nav |
|-----------|-------------|------------|
| `/video/` | `video_making` | Video tab |
| `/shop/` | `buy_sell` | Shop tab |
| `/dating/` | `dating` | Dating tab |
| `/social/` | `social_stumble` | Social tab |
| `/yoyo/` | `yoyo` | YoYo tab |
| `/chat/` | (cross-module) | Chat — uses Thread.moduleKey for context |
| `/profile/` | (cross-module) | Profile tab |
| `/notifications` | (cross-module) | Notifications screen |

---

## 3. Notification Payload Schema

Every notification — whether delivered via FCM push, Socket.io, or stored in the database — carries a `data` field with a deep link.

### FCM Push Payload

```json
{
  "notification": {
    "title": "Maya accepted your offer!",
    "body": "Polaroid Camera — $42 agreed"
  },
  "data": {
    "type": "OFFER_ACCEPTED",
    "deepLink": "kuwboo://chat/thread-789?highlight=accepted-456",
    "moduleKey": "buy_sell",
    "threadId": "thread-789",
    "entityId": "product-123",
    "imageUrl": "https://cdn.kuwboo.com/products/polaroid-thumb.jpg",
    "groupKey": "offer:product-123",
    "accountId": "account-001"
  },
  "android": {
    "priority": "high"
  },
  "apns": {
    "payload": {
      "aps": {
        "badge": 3,
        "sound": "default",
        "mutable-content": 1
      }
    }
  }
}
```

### Notification Database Record

```typescript
// Matches TECHNICAL_DESIGN.md Notification entity (line 1066)
{
  id: "notif-uuid",
  userId: "user-uuid",
  type: "OFFER_ACCEPTED",       // NotificationType enum
  title: "Maya accepted your offer!",
  body: "Polaroid Camera — $42 agreed",
  data: {                        // JSONB deep-link payload
    deepLink: "kuwboo://chat/thread-789?highlight=accepted-456",
    moduleKey: "buy_sell",
    threadId: "thread-789",
    entityId: "product-123",
    imageUrl: "https://cdn.kuwboo.com/products/polaroid-thumb.jpg"
  },
  readAt: null,
  groupKey: "offer:product-123",
  createdAt: "2026-03-26T10:48:00Z"
}
```

### Socket.io In-App Event

```typescript
// Emitted on /notifications namespace → user:{userId} room
socket.emit('notification:new', {
  id: "notif-uuid",
  type: "OFFER_ACCEPTED",
  title: "Maya accepted your offer!",
  body: "Polaroid Camera — $42 agreed",
  deepLink: "kuwboo://chat/thread-789?highlight=accepted-456",
  imageUrl: "https://cdn.kuwboo.com/products/polaroid-thumb.jpg",
  createdAt: "2026-03-26T10:48:00Z"
});
```

### Notification Type → Deep Link Mapping

| NotificationType | Deep Link Pattern | Example |
|-----------------|-------------------|---------|
| `LIKE` | `kuwboo://<module>/<contentType>/<contentId>` | `kuwboo://video/abc123` |
| `COMMENT` | `kuwboo://<module>/<contentType>/<contentId>?comment=<commentId>` | `kuwboo://social/post/xyz?comment=c456` |
| `FOLLOW` | `kuwboo://profile/<followerId>` | `kuwboo://profile/user-789` |
| `MATCH` | `kuwboo://dating/profile/<matchedUserId>` | `kuwboo://dating/profile/user-345` |
| `MESSAGE` | `kuwboo://chat/<threadId>` | `kuwboo://chat/thread-789` |
| `BID` | `kuwboo://shop/product/<productId>` | `kuwboo://shop/product/prod-456` |
| `AUCTION_ENDING` | `kuwboo://shop/product/<productId>` | `kuwboo://shop/product/prod-456` |
| `AUCTION_WON` | `kuwboo://chat/<threadId>` | `kuwboo://chat/thread-seller` |
| `AUCTION_OUTBID` | `kuwboo://shop/product/<productId>` | `kuwboo://shop/product/prod-456` |
| `MENTION` | `kuwboo://<module>/<contentType>/<contentId>` | `kuwboo://social/post/xyz` |
| `YOYO_NEARBY` | `kuwboo://yoyo/nearby` | `kuwboo://yoyo/nearby` |
| `SYSTEM` | `kuwboo://notifications` | `kuwboo://notifications` |

---

## 4. Flutter Router Design

### go_router Setup

```dart
// lib/router/app_router.dart
final router = GoRouter(
  initialLocation: '/video/feed',
  redirect: _authGuard,
  routes: [
    // Module shells with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) => AppShell(child: child),
      branches: [
        StatefulShellBranch(routes: _videoRoutes),
        StatefulShellBranch(routes: _datingRoutes),
        StatefulShellBranch(routes: _yoyoRoutes),
        StatefulShellBranch(routes: _socialRoutes),
        StatefulShellBranch(routes: _shopRoutes),
      ],
    ),
    // Cross-module routes (no bottom nav shell)
    ..._chatRoutes,
    ..._profileRoutes,
    ..._notificationRoutes,
    ..._authRoutes,
  ],
);

// Example: chat routes with typed parameters
List<RouteBase> get _chatRoutes => [
  GoRoute(
    path: '/chat/inbox',
    builder: (context, state) => const ChatInboxScreen(),
  ),
  GoRoute(
    path: '/chat/:threadId',
    builder: (context, state) {
      final threadId = state.pathParameters['threadId']!;
      final messageId = state.uri.queryParameters['message'];
      final highlight = state.uri.queryParameters['highlight'];
      return ChatConversationScreen(
        threadId: threadId,
        scrollToMessageId: messageId,
        highlightCard: highlight,
      );
    },
  ),
];
```

### Auth Guard

```dart
String? _authGuard(BuildContext context, GoRouterState state) {
  final auth = AuthProvider.of(context);
  final isAuthRoute = state.matchedLocation.startsWith('/auth/');

  if (!auth.isAuthenticated && !isAuthRoute) {
    // Save intended deep link for post-login redirect
    auth.pendingDeepLink = state.uri.toString();
    return '/auth/welcome';
  }

  // COPPA: age-blocked users can't access dating or marketplace
  if (auth.isAgeBlocked) {
    final blocked = ['/dating/', '/shop/'];
    if (blocked.any((p) => state.matchedLocation.startsWith(p))) {
      return '/auth/age-block';
    }
  }

  return null; // No redirect
}
```

### Deep Link Handling on App Start

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1. Handle notification tap that launched the app
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  String? initialDeepLink;
  if (initialMessage != null) {
    initialDeepLink = initialMessage.data['deepLink'];
  }

  // 2. Handle Firebase Dynamic Links that launched the app
  final dynamicLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if (dynamicLink != null) {
    initialDeepLink ??= dynamicLink.link.toString();
  }

  runApp(KuwbooApp(initialDeepLink: initialDeepLink));
}
```

### Notification Tap While App Is Open

```dart
// In app initialization (e.g., AppShell widget)
@override
void initState() {
  super.initState();

  // FCM: notification tapped while app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final deepLink = message.data['deepLink'];
    if (deepLink != null) {
      GoRouter.of(context).go(deepLink.replaceFirst('kuwboo://', '/'));
    }
  });

  // Socket.io: in-app notification banner tap
  notificationService.onNotificationTap.listen((notification) {
    GoRouter.of(context).go(
      notification.deepLink.replaceFirst('kuwboo://', '/'),
    );
  });
}
```

---

## 5. In-App Notification Routing

### Notification Banner (Foreground)

When a notification arrives while the app is open:

```
┌─────────────────────────────────────────────────┐
│  [Avatar]  Maya accepted your offer!            │
│            Polaroid Camera — $42 agreed    [→]  │
└─────────────────────────────────────────────────┘
                   ↓ tap
       router.go('/chat/thread-789?highlight=accepted-456')
```

- Banner shows for 4 seconds, auto-dismisses
- Tap navigates using `deepLink` from the Socket.io event
- Swipe up to dismiss
- Don't show banners for the screen the user is currently on

### Notification Inbox

```dart
// Tap handler in notification inbox list
onTap: () {
  // Mark as read
  notificationService.markRead(notification.id);
  // Navigate
  final path = notification.data['deepLink']
      .replaceFirst('kuwboo://', '/');
  GoRouter.of(context).go(path);
}
```

---

## 6. Message-Level Deep Linking

Three levels of precision for chat deep links:

| Level | URL | Behavior |
|-------|-----|----------|
| **Thread** | `kuwboo://chat/:threadId` | Open conversation, scroll to bottom |
| **Message** | `kuwboo://chat/:threadId?message=:messageId` | Open conversation, scroll to message, highlight with pulse animation |
| **Transaction card** | `kuwboo://chat/:threadId?highlight=:cardType-:cardId` | Open conversation, scroll to card, highlight border pulse |

### Scroll-to-Message Implementation

```dart
class ChatConversationScreen extends StatefulWidget {
  final String threadId;
  final String? scrollToMessageId;
  final String? highlightCard;
  // ...
}

// In initState or after messages load:
void _scrollToTarget() {
  if (widget.scrollToMessageId != null) {
    final index = _messages.indexWhere(
      (m) => m.id == widget.scrollToMessageId,
    );
    if (index >= 0) {
      _scrollController.animateTo(
        _calculateOffset(index),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // Highlight with a brief pulse
      setState(() => _highlightedIndex = index);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _highlightedIndex = null);
      });
    }
  }
}
```

---

## 7. Sharing

### Share Flow

```
User taps Share → generate universal link → copy/send

Universal link format:
  https://app.kuwboo.com/video/abc123
  https://app.kuwboo.com/shop/product/def456
  https://app.kuwboo.com/profile/user-789

Recipient taps link:
  ├── App installed → opens app at correct screen (via Firebase Dynamic Links)
  └── App not installed → opens web fallback (marketing page with app store links)
```

### Firebase Dynamic Links Configuration

```
Domain: kuwboo.page.link (existing from legacy iOS app)
Fallback: https://kuwboo.com (marketing site)
iOS bundle: com.lionprodev.kuwboo
Android package: com.lionprodev.kuwboo
```

### Link Generation (Backend)

```typescript
// POST /api/share/link
async generateShareLink(params: {
  module: ModuleScope;
  contentType: string;
  contentId: string;
}): Promise<string> {
  const path = `/${params.module}/${params.contentType}/${params.contentId}`;
  const dynamicLink = await firebase.dynamicLinks().createLink({
    link: `https://app.kuwboo.com${path}`,
    domainUriPrefix: 'https://kuwboo.page.link',
    android: { packageName: 'com.lionprodev.kuwboo' },
    ios: { bundleId: 'com.lionprodev.kuwboo' },
  });
  return dynamicLink.shortLink;
}
```

---

## 8. Multi-Account Awareness

Kuwboo supports multi-account switching (see `MULTI_ACCOUNT_DESIGN.md`). Deep links must handle the case where the link targets a different account than the one currently active.

### FCM Token Registration

```typescript
// Backend: store token per (userId, deviceId, accountId)
interface DeviceToken {
  userId: string;
  deviceId: string;
  accountId: string;
  fcmToken: string;
  platform: 'ios' | 'android';
  isActive: boolean;  // only one accountId is active per device
}
```

### Account Switch on Deep Link

```dart
void _handleDeepLink(String deepLink, String? accountId) {
  final currentAccountId = authProvider.activeAccountId;

  if (accountId != null && accountId != currentAccountId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => AccountSwitchDialog(
        targetAccountId: accountId,
        onConfirm: () async {
          await authProvider.switchAccount(accountId);
          router.go(deepLink.replaceFirst('kuwboo://', '/'));
        },
      ),
    );
  } else {
    router.go(deepLink.replaceFirst('kuwboo://', '/'));
  }
}
```

---

## 9. Platform Configuration

### iOS — Info.plist

```xml
<!-- Custom URL scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>kuwboo</string>
    </array>
  </dict>
</array>

<!-- Universal Links (Associated Domains) -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:app.kuwboo.com</string>
  <string>applinks:kuwboo.page.link</string>
</array>
```

### Android — AndroidManifest.xml

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <!-- Universal links -->
  <data android:scheme="https" android:host="app.kuwboo.com" />
  <data android:scheme="https" android:host="kuwboo.page.link" />
  <!-- Custom scheme -->
  <data android:scheme="kuwboo" />
</intent-filter>
```

### Flutter Dependencies

```yaml
# pubspec.yaml additions for deep linking
dependencies:
  go_router: ^14.0.0
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  firebase_dynamic_links: ^6.0.0
  flutter_local_notifications: ^18.0.0
```

---

## 10. Backend Implementation Checklist

| Task | Module | Priority |
|------|--------|----------|
| Add `deepLink` field construction to `NotificationService.send()` | notifications | P0 |
| Add `deepLink` to FCM payload in `base-notification.ts` | notifications | P0 |
| Add `deepLink` to Socket.io `notification:new` events | notifications | P0 |
| Create `POST /api/share/link` endpoint for share link generation | sharing | P1 |
| Add `accountId` to device token registration | auth | P1 |
| Add notification type → deep link template mapping | notifications | P0 |
| Store Thread.moduleKey + Thread.contextId for chat context routing | chat | P0 |

---

## 11. Flutter Implementation Checklist

| Task | Priority |
|------|----------|
| Set up `go_router` with full route tree and typed parameters | P0 |
| Implement auth guard with pending deep link storage | P0 |
| Configure Firebase Messaging (permissions, token, handlers) | P0 |
| Handle notification tap (app closed, background, foreground) | P0 |
| Implement in-app notification banner with deep link tap | P1 |
| Implement scroll-to-message and highlight animation | P1 |
| Configure iOS Associated Domains and Android App Links | P1 |
| Set up Firebase Dynamic Links for sharing | P2 |
| Implement account switch dialog for cross-account deep links | P2 |
| Add share button with universal link generation | P2 |

---

## 12. Testing Strategy

### Unit Tests
- Deep link URL parsing → correct route + parameters
- Notification payload → correct deep link construction
- Auth guard redirects (unauthenticated, age-blocked)

### Integration Tests
- FCM notification → tap → correct screen opens
- Socket.io notification → banner → tap → correct screen
- Share link → Dynamic Link → app opens at correct screen
- Cross-account deep link → account switch dialog

### Manual Testing Matrix

| Source | State | Expected |
|--------|-------|----------|
| Push notification | App killed | App launches → auth (if needed) → target screen |
| Push notification | App backgrounded | App resumes → target screen |
| Push notification | App in foreground | Banner shows → tap → navigate |
| Universal link | App installed | App opens → target screen |
| Universal link | App not installed | Web fallback with app store links |
| Custom scheme | From another app | App opens → target screen |
| Notification inbox | Tap item | Navigate → target screen, mark read |
| Chat link | With message param | Scroll to message, highlight pulse |
