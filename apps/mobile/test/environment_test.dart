import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_mobile/config/environment.dart';

void main() {
  group('Environment', () {
    test('defaults to dev when KUWBOO_ENV is unset', () {
      // In test runs without --dart-define, defaults to dev
      expect(Environment.current, 'dev');
    });

    test('apiBaseUrl returns a URL without trailing slash', () {
      // Dev currently points to the greenfield EC2 over plain HTTP
      // until TLS is provisioned. Prod uses HTTPS.
      final url = Environment.apiBaseUrl;
      expect(url, anyOf(startsWith('http://'), startsWith('https://')));
      expect(url, isNot(endsWith('/')));
    });

    test('isProduction is false in dev', () {
      expect(Environment.isProduction, isFalse);
      expect(Environment.isDev, isTrue);
    });
  });
}
