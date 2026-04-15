import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

/// Records each outbound request and returns a canned JSON response.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<Map<String, dynamic>> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = await handler(options);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

KuwbooApiClient _buildClient(_FakeAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return KuwbooApiClient(baseUrl: 'https://api.test', dio: dio);
}

Map<String, dynamic> _wrap(Object data) => {'data': data};

final _productJson = {
  'id': 'p1',
  'creatorId': 'u1',
  'title': 'Vintage Lamp',
  'description': 'Brass, 1960s',
  'priceCents': 4500,
  'currency': 'GBP',
  'condition': 'GOOD',
  'isDeal': false,
  'status': 'ACTIVE',
  'likeCount': 0,
  'commentCount': 0,
  'createdAt': '2026-04-15T10:00:00.000Z',
};

final _auctionJson = {
  'id': 'a1',
  'productId': 'p1',
  'startPriceCents': 1000,
  'currentPriceCents': 1000,
  'minIncrementCents': 100,
  'startsAt': '2026-04-15T10:00:00.000Z',
  'endsAt': '2026-04-20T10:00:00.000Z',
  'status': 'ACTIVE',
  'createdAt': '2026-04-15T09:00:00.000Z',
};

final _bidJson = {
  'id': 'b1',
  'auctionId': 'a1',
  'bidderId': 'u2',
  'amountCents': 1500,
  'placedAt': '2026-04-16T10:00:00.000Z',
};

final _ratingJson = {
  'id': 'r1',
  'buyerId': 'u2',
  'sellerId': 'u1',
  'productId': 'p1',
  'rating': 5,
  'review': 'Great!',
  'createdAt': '2026-04-17T10:00:00.000Z',
};

void main() {
  // flutter_secure_storage is invoked by the auth interceptor on every
  // request. In a unit test there's no real platform channel, so we
  // stub it to always return null (no stored token).
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);

  group('MarketplaceApi', () {
    test('createProduct POSTs to /products and decodes Product', () async {
      final adapter = _FakeAdapter((_) async => _wrap(_productJson));
      final api = MarketplaceApi(_buildClient(adapter));

      final product = await api.createProduct(
        title: 'Vintage Lamp',
        description: 'Brass, 1960s',
        priceCents: 4500,
        condition: 'GOOD',
      );

      expect(adapter.requests, hasLength(1));
      final req = adapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/products');
      expect(req.data, isA<Map<String, dynamic>>());
      expect((req.data as Map)['priceCents'], 4500);
      expect((req.data as Map)['condition'], 'GOOD');
      expect(product.id, 'p1');
      expect(product.priceCents, 4500);
    });

    test('listProducts forwards all filters and decodes ProductPage',
        () async {
      final adapter = _FakeAdapter(
        (_) async => _wrap({
          'items': [_productJson],
          'nextCursor': '2026-04-15T09:00:00.000Z',
        }),
      );
      final api = MarketplaceApi(_buildClient(adapter));

      final page = await api.listProducts(
        category: 'furniture',
        minPrice: 1000,
        maxPrice: 10000,
        condition: 'GOOD',
        cursor: 'prev',
        limit: 25,
      );

      final req = adapter.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/products');
      expect(req.queryParameters, {
        'category': 'furniture',
        'minPrice': 1000,
        'maxPrice': 10000,
        'condition': 'GOOD',
        'cursor': 'prev',
        'limit': 25,
      });
      expect(page.items, hasLength(1));
      expect(page.items.single.id, 'p1');
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, '2026-04-15T09:00:00.000Z');
    });

    test('getDeals paginates with cursor + limit', () async {
      final adapter = _FakeAdapter(
        (_) async => _wrap({
          'items': [_productJson],
          'nextCursor': null,
        }),
      );
      final api = MarketplaceApi(_buildClient(adapter));

      final page = await api.getDeals(cursor: 'c1', limit: 10);

      final req = adapter.requests.single;
      expect(req.path, '/products/deals');
      expect(req.queryParameters, {'cursor': 'c1', 'limit': 10});
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
    });

    test('createAuction POSTs to /auctions with ISO dates', () async {
      final adapter = _FakeAdapter((_) async => _wrap(_auctionJson));
      final api = MarketplaceApi(_buildClient(adapter));

      final starts = DateTime.utc(2026, 4, 15, 10);
      final ends = DateTime.utc(2026, 4, 20, 10);
      final auction = await api.createAuction(
        productId: 'p1',
        startPriceCents: 1000,
        startsAt: starts,
        endsAt: ends,
        minIncrementCents: 100,
        antiSnipeMinutes: 2,
      );

      final req = adapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/auctions');
      final body = req.data as Map<String, dynamic>;
      expect(body['productId'], 'p1');
      expect(body['startsAt'], starts.toIso8601String());
      expect(body['endsAt'], ends.toIso8601String());
      expect(auction.id, 'a1');
      expect(auction.status, 'ACTIVE');
    });

    test('placeBid POSTs to /auctions/:id/bid and decodes Bid', () async {
      final adapter = _FakeAdapter((_) async => _wrap(_bidJson));
      final api = MarketplaceApi(_buildClient(adapter));

      final bid =
          await api.placeBid(auctionId: 'a1', amountCents: 1500);

      final req = adapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/auctions/a1/bid');
      expect((req.data as Map)['amountCents'], 1500);
      expect(bid.amountCents, 1500);
      expect(bid.auctionId, 'a1');
    });

    test('getAuction decodes AuctionWithBids envelope', () async {
      final adapter = _FakeAdapter(
        (_) async => _wrap({
          'auction': _auctionJson,
          'bids': [_bidJson],
        }),
      );
      final api = MarketplaceApi(_buildClient(adapter));

      final result = await api.getAuction('a1');

      final req = adapter.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/auctions/a1');
      expect(result.auction.id, 'a1');
      expect(result.bids, hasLength(1));
      expect(result.bids.single.id, 'b1');
    });

    test('rateSeller POSTs to /users/:id/ratings', () async {
      final adapter = _FakeAdapter((_) async => _wrap(_ratingJson));
      final api = MarketplaceApi(_buildClient(adapter));

      final rating = await api.rateSeller(
        sellerId: 'u1',
        productId: 'p1',
        rating: 5,
        review: 'Great!',
      );

      final req = adapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/users/u1/ratings');
      final body = req.data as Map<String, dynamic>;
      expect(body['productId'], 'p1');
      expect(body['rating'], 5);
      expect(body['review'], 'Great!');
      expect(rating.sellerId, 'u1');
      expect(rating.rating, 5);
    });

    test('getSellerRatings decodes SellerRatingPage with average', () async {
      final adapter = _FakeAdapter(
        (_) async => _wrap({
          'items': [_ratingJson],
          'nextCursor': null,
          'averageRating': 4.8,
        }),
      );
      final api = MarketplaceApi(_buildClient(adapter));

      final page = await api.getSellerRatings('u1', limit: 20);

      final req = adapter.requests.single;
      expect(req.path, '/users/u1/ratings');
      expect(req.queryParameters, {'limit': 20});
      expect(page.averageRating, 4.8);
      expect(page.items.single.id, 'r1');
      expect(page.hasMore, isFalse);
    });
  });
}
