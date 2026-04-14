import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

void main() {
  test('KuwbooApiClient + AuthApi construct', () {
    final client = KuwbooApiClient(baseUrl: 'https://example.test', dio: Dio());
    expect(client, isNotNull);
    expect(client.dio.options.baseUrl, 'https://example.test');
    expect(AuthApi(client), isNotNull);
  });
}
