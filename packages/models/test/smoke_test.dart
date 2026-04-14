import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026);

  test('User constructs with defaults', () {
    final user = User(id: 'u1', createdAt: now);
    expect(user.id, 'u1');
    expect(user.role, Role.user);
    expect(user.status, UserStatus.active);
    expect(user.onboardingProgress, OnboardingProgress.welcome);
    expect(user.ageVerificationStatus, AgeVerificationStatus.selfDeclared);
    expect(user.birthdaySkipped, false);
    expect(user.profileCompletenessPct, 0);
  });

  test('Credential constructs', () {
    final c = Credential(
      id: 'c1',
      userId: 'u1',
      type: CredentialType.phone,
      identifier: '+447700900000',
      verifiedAt: now,
      createdAt: now,
    );
    expect(c.type, CredentialType.phone);
    expect(c.isPrimary, false);
  });

  test('TrustSignal constructs', () {
    final s = TrustSignal(
      id: 's1',
      userId: 'u1',
      signalType: 'phone_verified_mobile',
      delta: 20,
      createdAt: now,
    );
    expect(s.delta, 20);
  });

  test('Interest + UserInterest + InterestSignal construct', () {
    final i = Interest(
      id: 'i1',
      slug: 'photography',
      label: 'Photography',
      createdAt: now,
      updatedAt: now,
    );
    expect(i.isActive, true);
    final ui = UserInterest(
      id: 'ui1',
      userId: 'u1',
      interestId: 'i1',
      selectedAt: now,
    );
    expect(ui.interestId, 'i1');
    final sig = InterestSignal(
      id: 'is1',
      userId: 'u1',
      interestId: 'i1',
      lastSeenAt: now,
    );
    expect(sig.weight, 0.0);
  });

  test('AuthResponse and PendingSsoChallenge construct', () {
    final auth = AuthResponse(
      accessToken: 'a',
      refreshToken: 'r',
      user: User(id: 'u1', createdAt: now),
    );
    expect(auth.isNewUser, false);
    final challenge = PendingSsoChallenge(
      code: 'email_owned',
      challengeId: 'ch1',
      email: 'u@example.com',
    );
    expect(challenge.requireVerifyEmail, true);
  });
}
