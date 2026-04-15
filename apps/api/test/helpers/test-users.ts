/**
 * Test helpers for creating authenticated users inside E2E specs.
 */
import { randomUUID } from 'crypto';
import { EntityManager } from '@mikro-orm/postgresql';
import { JwtService } from '@nestjs/jwt';
import { User } from '../../src/modules/users/entities/user.entity';
import { Role, UserStatus, OnboardingProgress } from '../../src/common/enums';

export interface CreateTestUserOptions {
  withDob?: boolean;
  role?: Role;
  onboardingComplete?: boolean;
  phone?: string;
}

export async function createTestUser(
  em: EntityManager,
  opts: CreateTestUserOptions = {},
): Promise<User> {
  const fork = em.fork();
  // Generate a plausible-looking E.164 phone number with a random suffix
  // so concurrent specs don't collide on the unique constraint.
  const phone =
    opts.phone ??
    `+1415${Math.floor(2000000 + Math.random() * 7999999).toString()}`;

  const user = fork.create(User, {
    name: `test-${randomUUID().slice(0, 8)}`,
    phone,
    role: opts.role ?? Role.USER,
    status: UserStatus.ACTIVE,
    onboardingProgress: opts.onboardingComplete
      ? OnboardingProgress.COMPLETE
      : OnboardingProgress.OTP,
    dateOfBirth: opts.withDob ? new Date('1995-06-15') : undefined,
  } as never);

  await fork.flush();
  return user;
}

/**
 * Mint a short-lived access token matching the shape produced by
 * AuthService.issueTokens() — sub / role / jti — and sign it with the
 * same secret the JwtStrategy verifies against.
 */
export function authHeader(
  jwtService: JwtService,
  user: Pick<User, 'id' | 'role'>,
): { Authorization: string } {
  const token = jwtService.sign(
    { sub: user.id, role: user.role, jti: randomUUID() },
    {
      secret: process.env.JWT_ACCESS_SECRET,
      expiresIn: '15m',
    },
  );
  return { Authorization: `Bearer ${token}` };
}
