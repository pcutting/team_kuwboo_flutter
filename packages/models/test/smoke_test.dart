import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:test/test.dart';

void main() {
  test('User constructs with defaults', () {
    final user = User(id: 'u1', createdAt: DateTime.utc(2026));
    expect(user.id, 'u1');
    expect(user.role, Role.user);
    expect(user.status, UserStatus.active);
  });
}
