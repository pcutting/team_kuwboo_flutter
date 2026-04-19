// Web-prototype mock for the Kuwboo HTTP API.
//
// The shared screens packages (`kuwboo_screens`, `kuwboo_chat`, etc.) issue
// real HTTP calls through `KuwbooApiClient`. The mobile app overrides their
// `apiClientProvider` with an authenticated client. The web prototype has no
// backend (it ships as a static Vercel bundle), so we install a Dio
// interceptor that short-circuits every request with canned JSON matching
// the backend envelope (`{data: ...}` or bare lists where applicable).
//
// Add new endpoints below as the prototype grows.

import 'package:dio/dio.dart';

class MockApiInterceptor extends Interceptor {
  MockApiInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final response = _handle(options);
    handler.resolve(response);
  }

  Response<dynamic> _handle(RequestOptions options) {
    final method = options.method.toUpperCase();
    final path = options.path;

    if (method == 'POST' && path == '/auth/logout') {
      return Response<dynamic>(
        requestOptions: options,
        statusCode: 204,
        data: null,
      );
    }

    final body = _route(method, path, options);
    return Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
      data: body,
    );
  }

  Map<String, dynamic> _route(
    String method,
    String path,
    RequestOptions options,
  ) {
    // Strip query string. We key only on method+path; parameters do not
    // change the canned response.
    if (method == 'GET') {
      // Feed (video / social / shop / home).
      if (path == '/feed' || path == '/feed/following') {
        final tab = options.queryParameters['tab']?.toString() ?? 'home';
        return _envelope(_feedResponse(tab));
      }
      if (path == '/feed/trending' || path == '/feed/discover') {
        final tab = options.queryParameters['tab']?.toString() ?? 'home';
        return _envelope(_feedResponse(tab)['items']);
      }

      // Comments.
      if (RegExp(r'^/content/[^/]+/comments$').hasMatch(path)) {
        return _envelope(_commentsList());
      }
      if (RegExp(r'^/content/[^/]+/interactions$').hasMatch(path)) {
        return _envelope(<String, dynamic>{
          'liked': false,
          'saved': false,
          'likeCount': 142,
          'saveCount': 18,
          'viewCount': 2310,
          'shareCount': 24,
          'commentCount': _commentsList().length,
        });
      }

      // Users.
      if (path == '/users/me') return _envelope(_meUser());
      if (path == '/users/me/interests') {
        return _envelope(<String, dynamic>{'interests': _userInterests()});
      }
      if (path == '/users/username-available') {
        return _envelope(<String, dynamic>{'available': true});
      }
      if (RegExp(r'^/users/[^/]+/ratings$').hasMatch(path)) {
        return _envelope(<String, dynamic>{
          'items': <dynamic>[],
          'averageRating': 0.0,
        });
      }
      if (RegExp(r'^/users/[^/]+$').hasMatch(path)) {
        return _envelope(_meUser());
      }

      // Notifications.
      if (path == '/notifications') {
        return _envelope(<String, dynamic>{'items': <dynamic>[]});
      }
      if (path == '/notifications/unread-count') {
        return _envelope(<String, dynamic>{'count': 3});
      }
      if (path == '/notifications/preferences') {
        return _envelope(<dynamic>[]);
      }

      // Interests / credentials catalogues.
      if (path == '/interests') {
        return _envelope(<String, dynamic>{'interests': _userInterests()});
      }
      if (path == '/credentials') {
        return _envelope(<String, dynamic>{'credentials': <dynamic>[]});
      }

      // Marketplace.
      if (path == '/products' || path == '/products/deals') {
        return _envelope(<String, dynamic>{
          'items': _products(),
          'nextCursor': null,
        });
      }
      if (RegExp(r'^/products/[^/]+$').hasMatch(path)) {
        return _envelope(_products().first);
      }
      if (RegExp(r'^/auctions/[^/]+$').hasMatch(path)) {
        return _envelope(_auctionWithBids());
      }

      // Dating.
      if (path == '/dating/discover') {
        return _envelope(<String, dynamic>{
          'items': _datingCards(),
          'nextCursor': null,
          'hasMore': false,
        });
      }
      if (path == '/dating/matches') {
        return _envelope(<String, dynamic>{'matches': <dynamic>[]});
      }
      if (path == '/dating/likes') {
        return _envelope(<String, dynamic>{'likes': <dynamic>[]});
      }

      // Threads / messaging.
      if (path == '/threads') {
        return _envelope(<String, dynamic>{
          'items': _threads(),
          'nextCursor': null,
        });
      }
      if (RegExp(r'^/threads/[^/]+/messages$').hasMatch(path)) {
        return _envelope(<String, dynamic>{
          'items': _messages(),
          'nextCursor': null,
        });
      }

      // Connections (offset paginated, returned as bare list).
      if (path == '/connections/followers' ||
          path == '/connections/following') {
        return _envelope(<dynamic>[]);
      }
      if (path == '/blocks') {
        return _envelope(<dynamic>[]);
      }

      // YoYo.
      if (path == '/yoyo/nearby') {
        return _envelope(_nearbyUsers());
      }
      if (path == '/yoyo/settings') {
        return _envelope(<String, dynamic>{
          'isVisible': true,
          'radiusKm': 10,
          'ageMin': null,
          'ageMax': null,
          'genderFilter': null,
        });
      }
      if (path == '/yoyo/waves') {
        return _envelope(_waves());
      }
    }

    if (method == 'POST') {
      if (RegExp(r'^/content/[^/]+/like$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'liked': true, 'likeCount': 143});
      }
      if (RegExp(r'^/content/[^/]+/save$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'saved': true, 'saveCount': 19});
      }
      if (RegExp(r'^/content/[^/]+/(view|share)$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'ok': true});
      }
      if (RegExp(r'^/content/[^/]+/comments$').hasMatch(path)) {
        // Echo the submitted text back so the caller sees the comment it
        // just posted appear in the list, rather than a canned reply.
        final contentId = RegExp(r'^/content/([^/]+)/comments$')
                .firstMatch(path)
                ?.group(1) ??
            'demo-content-1';
        final raw = options.data;
        String text = '';
        String? parentCommentId;
        if (raw is Map) {
          text = (raw['text'] as String?)?.trim() ?? '';
          parentCommentId = raw['parentCommentId'] as String?;
        }
        return _envelope(<String, dynamic>{
          'id': 'demo-comment-${DateTime.now().microsecondsSinceEpoch}',
          'contentId': contentId,
          'authorId': 'demo-user-me',
          'text': text,
          'likeCount': 0,
          'replyCount': 0,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      if (RegExp(r'^/comments/[^/]+/like$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'liked': true});
      }
      if (path == '/threads') {
        return _envelope(_threads().first);
      }
      if (RegExp(r'^/threads/[^/]+/messages$').hasMatch(path)) {
        return _envelope(_messages().first);
      }
      if (path == '/yoyo/location' || path == '/yoyo/wave') {
        return _envelope(<String, dynamic>{'message': 'ok'});
      }

      // Email + password (PR B). The prototype has no real auth store —
      // any credentials succeed and the canned `_meUser()` payload is
      // returned alongside mock tokens. The register endpoint echoes the
      // submitted email / name into the user payload so the subsequent
      // onboarding screens see what the user typed.
      if (path == '/auth/email/register') {
        final raw = options.data;
        final email = raw is Map ? raw['email'] as String? : null;
        final name = raw is Map ? raw['name'] as String? : null;
        final user = Map<String, dynamic>.from(_meUser());
        if (email != null && email.isNotEmpty) user['email'] = email;
        if (name != null && name.isNotEmpty) user['name'] = name;
        return _envelope(<String, dynamic>{
          'accessToken': 'mock-access',
          'refreshToken': 'mock-refresh',
          'user': user,
          'isNewUser': true,
        });
      }
      if (path == '/auth/email/login') {
        final raw = options.data;
        final email = raw is Map ? raw['email'] as String? : null;
        final user = Map<String, dynamic>.from(_meUser());
        if (email != null && email.isNotEmpty) user['email'] = email;
        return _envelope(<String, dynamic>{
          'accessToken': 'mock-access',
          'refreshToken': 'mock-refresh',
          'user': user,
          'isNewUser': false,
        });
      }
    }

    if (method == 'PATCH') {
      if (path == '/yoyo/settings') {
        return _envelope(<String, dynamic>{
          'isVisible': true,
          'radiusKm': 10,
          'ageMin': null,
          'ageMax': null,
          'genderFilter': null,
        });
      }
      if (RegExp(r'^/threads/[^/]+/read$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'message': 'ok'});
      }
      if (path == '/notifications/read-all' ||
          RegExp(r'^/notifications/[^/]+/read$').hasMatch(path)) {
        return _envelope(<String, dynamic>{'message': 'ok'});
      }
    }

    // Unknown route — return an empty envelope so unmodelled calls don't
    // throw. The screens that hit them will render a sensible empty state.
    return _envelope(<String, dynamic>{});
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  Map<String, dynamic> _envelope(dynamic data) => <String, dynamic>{'data': data};

  // ─── Demo data ─────────────────────────────────────────────────────────

  static const _avatars = <String>[
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200&h=200&fit=crop',
  ];

  static const _names = <String>[
    'Maya',
    'Jordan',
    'Sam',
    'Riley',
    'Alex',
    'Charlie',
    'Ava',
    'Kai',
  ];

  static const _captions = <String>[
    'Golden hour vibes in Brick Lane.',
    'Tried the new ramen spot — worth the queue.',
    'Sunday studio sesh, new track dropping soon.',
    'When the light hits just right.',
    'Coffee ritual: pour-over, no shortcut.',
    'Fresh kicks, fresh start.',
    'Tonight\u2019s skyline beats every filter.',
    'Quick edit between meetings.',
  ];

  Map<String, dynamic> _meUser() => <String, dynamic>{
        'id': 'demo-user-me',
        'name': 'Demo User',
        'username': 'demo',
        'email': 'demo@kuwboo.app',
        'phone': '+447000000000',
        'avatarUrl': _avatars[4],
        'bio': 'Exploring Kuwboo. Founder of nothing yet.',
        'profileCompletenessPct': 65,
        'tutorialVersion': 1,
        'birthdaySkipped': false,
        'isBot': false,
        'appleEmailIsPrivateRelay': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
      };

  Map<String, dynamic> _feedResponse(String tab) {
    final type = switch (tab) {
      'shop' => 'PRODUCT',
      'social' => 'POST',
      _ => 'VIDEO',
    };
    // Every piece of canned content resolves its comment list to the same
    // fixed-length demo list (see `_commentsList()`), so seed the feed-
    // level `commentCount` with the same value rather than a formula that
    // drifts out of sync with the sheet (the "4 vs 5" off-by-one).
    final commentCount = _commentsList().length;
    final items = List<Map<String, dynamic>>.generate(8, (i) {
      final isPost = type == 'POST';
      final isProduct = type == 'PRODUCT';
      return <String, dynamic>{
        'id': 'demo-${tab}-$i',
        'type': type,
        'creator': <String, dynamic>{
          'id': 'demo-user-$i',
          'name': _names[i % _names.length],
          'avatarUrl': _avatars[i % _avatars.length],
        },
        'visibility': 'PUBLIC',
        'tier': 'FREE',
        'status': 'ACTIVE',
        'likeCount': 50 + i * 17,
        'commentCount': commentCount,
        'viewCount': 1200 + i * 87,
        'shareCount': 6 + i,
        'saveCount': 12 + i,
        'createdAt': DateTime.now()
            .subtract(Duration(hours: i + 1))
            .toIso8601String(),
        if (isPost) 'text': _captions[i % _captions.length],
        if (isPost) 'subType': 'STANDARD',
        if (!isPost) 'caption': _captions[i % _captions.length],
        if (!isPost) 'videoUrl': 'https://example.com/video-$i.mp4',
        if (!isPost) 'thumbnailUrl': _avatars[i % _avatars.length],
        if (!isPost) 'durationSeconds': 30 + i * 5,
        if (isProduct) 'title': 'Vintage find #${i + 1}',
        if (isProduct) 'priceCents': (1500 + i * 750),
        if (isProduct) 'currency': 'GBP',
        if (isProduct) 'condition': 'GOOD',
      };
    });
    return <String, dynamic>{
      'items': items,
      'nextCursor': null,
      'hasMore': false,
    };
  }

  List<Map<String, dynamic>> _commentsList() {
    return List<Map<String, dynamic>>.generate(5, (i) {
      const lines = <String>[
        'This is incredible!',
        'Love the vibe.',
        'Where is this? Need to visit.',
        'Following for more!',
        'The lighting is perfect.',
      ];
      return <String, dynamic>{
        'id': 'demo-comment-$i',
        'contentId': 'demo-content-1',
        'authorId': 'demo-user-$i',
        'text': lines[i],
        'likeCount': 5 + i * 7,
        'replyCount': i,
        'createdAt': DateTime.now()
            .subtract(Duration(minutes: 5 + i * 5))
            .toIso8601String(),
      };
    });
  }

  List<Map<String, dynamic>> _userInterests() {
    const slugs = <String>['music', 'travel', 'photography', 'cooking', 'art'];
    return [
      for (var i = 0; i < slugs.length; i++)
        <String, dynamic>{
          'id': 'interest-$i',
          'slug': slugs[i],
          'label': slugs[i][0].toUpperCase() + slugs[i].substring(1),
          'displayOrder': i,
          'isActive': true,
        }
    ];
  }

  List<Map<String, dynamic>> _products() {
    return List<Map<String, dynamic>>.generate(8, (i) {
      return <String, dynamic>{
        'id': 'demo-product-$i',
        'creator': <String, dynamic>{
          'id': 'demo-user-$i',
          'name': _names[i % _names.length],
          'avatarUrl': _avatars[i % _avatars.length],
        },
        'title': 'Vintage find #${i + 1}',
        'description': 'A great piece in good condition. Smoke-free home.',
        'priceCents': 1500 + i * 750,
        'currency': 'GBP',
        'condition': i.isEven ? 'GOOD' : 'LIKE_NEW',
        'isDeal': i % 3 == 0,
        if (i % 3 == 0) 'originalPriceCents': 2500 + i * 750,
        'thumbnailUrl': _avatars[i % _avatars.length],
        'status': 'ACTIVE',
        'likeCount': 10 + i * 3,
        'commentCount': 2 + i,
        'createdAt': DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
      };
    });
  }

  Map<String, dynamic> _auctionWithBids() {
    final product = _products().first;
    final auction = <String, dynamic>{
      'id': 'demo-auction-1',
      'productId': product['id'],
      'startPriceCents': 1000,
      'currentPriceCents': 9500,
      'minIncrementCents': 500,
      'startsAt': DateTime.now()
          .subtract(const Duration(hours: 6))
          .toIso8601String(),
      'endsAt': DateTime.now()
          .add(const Duration(hours: 18))
          .toIso8601String(),
      'status': 'ACTIVE',
      'createdAt': DateTime.now()
          .subtract(const Duration(hours: 6))
          .toIso8601String(),
    };
    final bids = List<Map<String, dynamic>>.generate(4, (i) {
      return <String, dynamic>{
        'id': 'demo-bid-$i',
        'auctionId': 'demo-auction-1',
        'bidderId': 'demo-user-$i',
        'amountCents': 9500 - i * 1000,
        'createdAt': DateTime.now()
            .subtract(Duration(minutes: 5 + i * 12))
            .toIso8601String(),
      };
    });
    return <String, dynamic>{
      'auction': auction,
      'product': product,
      'bids': bids,
    };
  }

  List<Map<String, dynamic>> _datingCards() {
    return List<Map<String, dynamic>>.generate(6, (i) {
      return <String, dynamic>{
        'id': 'demo-dating-$i',
        'type': 'POST',
        'creator': <String, dynamic>{
          'id': 'demo-dating-user-$i',
          'name': _names[i % _names.length],
          'avatarUrl': _avatars[i % _avatars.length],
        },
        'visibility': 'PUBLIC',
        'tier': 'FREE',
        'status': 'ACTIVE',
        'likeCount': 20 + i,
        'commentCount': 0,
        'viewCount': 100 + i * 10,
        'shareCount': 0,
        'saveCount': 0,
        'createdAt': DateTime.now()
            .subtract(Duration(hours: i + 1))
            .toIso8601String(),
        'text': _captions[i % _captions.length],
        'subType': 'STANDARD',
      };
    });
  }

  List<Map<String, dynamic>> _threads() {
    return List<Map<String, dynamic>>.generate(5, (i) {
      const modules = <String>['YoYo', 'Dating', 'Market', 'Social', 'Video'];
      return <String, dynamic>{
        'id': 'demo-thread-${i + 100000}',
        'moduleKey': modules[i % modules.length],
        'lastMessageText': const [
          'See you there!',
          'Is the camera still available?',
          'Great recipe, thanks!',
          'Friday works for me',
          'Cool shot!',
        ][i],
        'lastMessageAt': DateTime.now()
            .subtract(Duration(minutes: 5 + i * 35))
            .toIso8601String(),
        'createdAt': DateTime.now()
            .subtract(Duration(days: 1 + i))
            .toIso8601String(),
      };
    });
  }

  List<Map<String, dynamic>> _messages() {
    const lines = <String>[
      'Hey! Loved your latest video',
      'Thanks! Took ages to edit',
      'The transition at 0:15 was so smooth',
      'I used a new plugin for that!',
      'What plugin? I need it',
      'See you there!',
    ];
    return [
      for (var i = 0; i < lines.length; i++)
        <String, dynamic>{
          'id': 'demo-msg-$i',
          'threadId': 'demo-thread-100000',
          'senderId': i.isEven ? 'demo-user-other' : 'demo-user-me',
          'text': lines[i],
          'createdAt': DateTime.now()
              .subtract(Duration(minutes: 30 - i * 5))
              .toIso8601String(),
        }
    ];
  }

  List<Map<String, dynamic>> _nearbyUsers() {
    return List<Map<String, dynamic>>.generate(6, (i) {
      return <String, dynamic>{
        'id': 'demo-nearby-$i',
        'name': _names[i % _names.length],
        'avatarUrl': _avatars[i % _avatars.length],
        'distanceMeters': 80 + i * 220,
        'onlineStatus': i.isEven ? 'ONLINE' : 'OFFLINE',
      };
    });
  }

  List<Map<String, dynamic>> _waves() {
    return List<Map<String, dynamic>>.generate(3, (i) {
      return <String, dynamic>{
        'id': 'demo-wave-$i',
        'fromUserId': 'demo-user-$i',
        'toUserId': 'demo-user-me',
        'fromUserName': _names[i % _names.length],
        'fromUserAvatar': _avatars[i % _avatars.length],
        'message': 'Hey there!',
        'status': 'PENDING',
        'createdAt': DateTime.now()
            .subtract(Duration(hours: i + 1))
            .toIso8601String(),
      };
    });
  }
}

/// Build a [Dio] instance preloaded with [MockApiInterceptor] so a
/// `KuwbooApiClient` constructed with this Dio responds to every HTTP call
/// with canned demo data — no network access required.
Dio buildMockDio() {
  final dio = Dio(BaseOptions(baseUrl: 'https://mock.kuwboo.local'));
  dio.interceptors.add(MockApiInterceptor());
  return dio;
}
