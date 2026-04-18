/**
 * Admin seed script. Creates (or upserts) two SUPER_ADMIN users with
 * email + bcrypt password credentials so the admin dashboard at
 * admin.kuwboo.com can be accessed via email+password login.
 *
 * Passwords MUST be supplied via env vars — this script does not
 * hard-code credentials:
 *
 *   ADMIN_PHIL_EMAIL     (default: cuttingphilip@gmail.com)
 *   ADMIN_PHIL_PASSWORD  (required)
 *   ADMIN_NEIL_EMAIL     (default: neildouglas33@hotmail.co.uk)
 *   ADMIN_NEIL_PASSWORD  (required)
 *
 * Run on EC2 (or locally against a greenfield DB):
 *   cd /home/ubuntu/team_kuwboo/apps/api
 *   ADMIN_PHIL_PASSWORD='...' ADMIN_NEIL_PASSWORD='...' \
 *     npm run build && npm run seed:admin
 *
 * Idempotent. If a user with the target email already exists, the
 * script upserts: passwordHash is rotated to the env-var value, role
 * is elevated to SUPER_ADMIN if below, and an EMAIL credential row is
 * ensured. No other fields on the existing user are touched.
 */
import { NestFactory } from '@nestjs/core';
import { EntityManager } from '@mikro-orm/postgresql';
import * as bcrypt from 'bcrypt';
import { AppModule } from '../app.module';
import { User } from '../modules/users/entities/user.entity';
import { Credential } from '../modules/credentials/entities/credential.entity';
import { Role, UserStatus, CredentialType } from '../common/enums';

const BCRYPT_ROUNDS = 10;

interface AdminSpec {
  label: string;
  email: string;
  password: string;
  name: string;
  username: string;
}

interface SeedResult {
  label: string;
  userId: string;
  created: boolean;
  roleElevated: boolean;
  credentialCreated: boolean;
}

export async function seedAdmin(
  em: EntityManager,
  spec: AdminSpec,
): Promise<SeedResult> {
  const tem = em.fork();
  const email = spec.email.toLowerCase();
  const passwordHash = await bcrypt.hash(spec.password, BCRYPT_ROUNDS);
  const now = new Date();

  let user = await tem.findOne(User, { email });
  let created = false;
  let roleElevated = false;

  if (user) {
    user.passwordHash = passwordHash;
    if (user.role !== Role.SUPER_ADMIN) {
      user.role = Role.SUPER_ADMIN;
      roleElevated = true;
    }
    user.emailVerified = true;
    user.emailVerifiedAt = user.emailVerifiedAt ?? now;
  } else {
    user = tem.create(User, {
      email,
      name: spec.name,
      username: spec.username,
      role: Role.SUPER_ADMIN,
      status: UserStatus.ACTIVE,
      passwordHash,
      emailVerified: true,
      emailVerifiedAt: now,
      avatarUrl: `https://i.pravatar.cc/300?u=${encodeURIComponent(email)}`,
    });
    created = true;
  }

  await tem.persistAndFlush(user);

  const existingCredential = await tem.findOne(Credential, {
    user: user.id,
    type: CredentialType.EMAIL,
    identifier: email,
  });

  let credentialCreated = false;
  if (!existingCredential) {
    tem.create(Credential, {
      user,
      type: CredentialType.EMAIL,
      identifier: email,
      verifiedAt: now,
      isPrimary: true,
    });
    await tem.flush();
    credentialCreated = true;
  }

  return {
    label: spec.label,
    userId: user.id,
    created,
    roleElevated,
    credentialCreated,
  };
}

function readSpecsFromEnv(): AdminSpec[] {
  const philPassword = process.env.ADMIN_PHIL_PASSWORD;
  const neilPassword = process.env.ADMIN_NEIL_PASSWORD;
  const missing: string[] = [];
  if (!philPassword) missing.push('ADMIN_PHIL_PASSWORD');
  if (!neilPassword) missing.push('ADMIN_NEIL_PASSWORD');
  if (missing.length) {
    throw new Error(
      `[seed:admin] Missing required env var(s): ${missing.join(', ')}`,
    );
  }
  return [
    {
      label: 'phil',
      email: process.env.ADMIN_PHIL_EMAIL ?? 'cuttingphilip@gmail.com',
      password: philPassword!,
      name: 'Phil Cutting',
      username: 'phil',
    },
    {
      label: 'neil',
      email: process.env.ADMIN_NEIL_EMAIL ?? 'neildouglas33@hotmail.co.uk',
      password: neilPassword!,
      name: 'Neil Douglas',
      username: 'neil',
    },
  ];
}

async function bootstrap() {
  const specs = readSpecsFromEnv();
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });
  try {
    const em = app.get(EntityManager);
    for (const spec of specs) {
      const r = await seedAdmin(em, spec);
      const verb = r.created
        ? 'created'
        : r.roleElevated
          ? 'elevated to SUPER_ADMIN'
          : 'password rotated';
      console.log(
        `[seed:admin] ${r.label} (${r.userId}): ${verb}` +
          (r.credentialCreated ? ' + EMAIL credential created' : ''),
      );
    }
  } finally {
    await app.close();
  }
}

if (require.main === module) {
  bootstrap().catch((err) => {
    console.error('[seed:admin] FAILED:', err);
    process.exit(1);
  });
}
