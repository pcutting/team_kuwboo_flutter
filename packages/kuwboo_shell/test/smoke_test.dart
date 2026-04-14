import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

void main() {
  test('shell exports resolve', () {
    expect(ProtoModule.values, isNotEmpty);
  });
}
