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
      // Feed vertical (video / social / Stumble / comments / interactions)
      // is de-mocked — it hits the live backend through the real
      // KuwbooApiClient. See apps/web/lib/mock/package_overrides.dart.

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

      // Threads / messaging vertical is de-mocked — see
      // apps/web/lib/mock/package_overrides.dart and
      // apps/web/lib/providers/api_provider.dart. The shared kuwboo_chat
      // package now consumes the real KuwbooApiClient.

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
      // Feed-vertical writes (content/comments interactions) and the
      // messaging vertical (thread create + send-message) are de-mocked —
      // they hit the live backend through the real KuwbooApiClient. See
      // apps/web/lib/mock/package_overrides.dart.
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

      // Password reset (PR C). Forgot returns an empty body; reset
      // returns the same mock AuthResponse the login/register paths
      // use so the prototype lands the user on an "authenticated"
      // session after demoing the flow.
      if (path == '/auth/email/password/forgot') {
        return _envelope(<String, dynamic>{});
      }
      if (path == '/auth/email/password/reset') {
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

  Map<String, dynamic> _envelope(dynamic data) => <String, dynamic>{
    'data': data,
  };

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
        },
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
      'endsAt': DateTime.now().add(const Duration(hours: 18)).toIso8601String(),
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
