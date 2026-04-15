import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Minimal in-memory HttpClientAdapter for unit tests.
///
/// Records every outgoing request and returns a caller-provided JSON
/// response body. Tests inspect [requests] to assert path/method/query/body.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this._responder);

  /// Maps an incoming request to a JSON-encodable body.
  final Object? Function(RequestOptions options) _responder;

  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = _responder(options);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(body ?? {})));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
