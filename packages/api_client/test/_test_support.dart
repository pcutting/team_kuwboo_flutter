import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

/// Stub the flutter_secure_storage method channel so the auth interceptor's
/// `getAccessToken()` call resolves to null in unit tests instead of blowing
/// up on a missing platform plugin. Call from `setUpAll` after
/// `TestWidgetsFlutterBinding.ensureInitialized()`.
void stubSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

/// In-process Dio adapter that records the last [RequestOptions] and
/// replies with a pre-baked JSON body.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this._responder);

  final Map<String, dynamic> Function(RequestOptions options) _responder;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final body = _responder(options);
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

({KuwbooApiClient client, RecordingAdapter adapter}) makeTestClient(
  Map<String, dynamic> Function(RequestOptions options) responder,
) {
  final dio = Dio();
  final adapter = RecordingAdapter(responder);
  dio.httpClientAdapter = adapter;
  final client = KuwbooApiClient(baseUrl: 'https://example.test', dio: dio);
  return (client: client, adapter: adapter);
}
