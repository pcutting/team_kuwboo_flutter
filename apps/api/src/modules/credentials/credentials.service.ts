import {
  Injectable,
  ConflictException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Credential } from './entities/credential.entity';
import { User } from '../users/entities/user.entity';
import { CredentialType } from '../../common/enums';

export interface AttachCredentialInput {
  userId: string;
  type: CredentialType;
  identifier: string;
  providerData?: Record<string, unknown>;
  verifiedAt?: Date;
}

/**
 * Low-level operations on the `credentials` table. Higher-level flows
 * (OTP verify, SSO exchange) live in AuthService and call into this
 * service to create / lookup rows.
 */
@Injectable()
export class CredentialsService {
  constructor(private readonly em: EntityManager) {}

  async findByIdentity(
    type: CredentialType,
    identifier: string,
  ): Promise<Credential | null> {
    return this.em.findOne(
      Credential,
      { type, identifier, revokedAt: null },
      { populate: ['user'] },
    );
  }

  async listForUser(userId: string, includeRevoked = false): Promise<Credential[]> {
    return this.em.find(
      Credential,
      includeRevoked
        ? { user: userId }
        : { user: userId, revokedAt: null },
      { orderBy: { createdAt: 'ASC' } },
    );
  }

  /**
   * Attach a verified credential to a user. Throws `ConflictException`
   * (409 `credential_in_use`) if the (type, identifier) pair is already
   * owned by another user. See IDENTITY_CONTRACT §4.8.
   */
  async attach(input: AttachCredentialInput): Promise<Credential> {
    const existing = await this.em.findOne(Credential, {
      type: input.type,
      identifier: input.identifier,
      revokedAt: null,
    });
    if (existing) {
      if (existing.user.id !== input.userId) {
        throw new ConflictException({
          code: 'credential_in_use',
          message: 'That credential is already attached to another account.',
        });
      }
      return existing;
    }

    const user = await this.em.findOne(User, { id: input.userId });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const existingOfType = await this.em.findOne(Credential, {
      user: input.userId,
      type: input.type,
      revokedAt: null,
    });

    const credential = this.em.create(Credential, {
      user,
      type: input.type,
      identifier: input.identifier,
      providerData: input.providerData,
      verifiedAt: input.verifiedAt ?? new Date(),
      isPrimary: !existingOfType,
    } as any);

    await this.em.flush();
    return credential;
  }

  /**
   * Revoke (soft-delete) a credential owned by the user. Enforces "cannot
   * revoke last active credential" — IDENTITY_CONTRACT §11.2.
   */
  async revoke(credentialId: string, ownerUserId: string): Promise<Credential> {
    const credential = await this.em.findOne(
      Credential,
      { id: credentialId },
      { populate: ['user'] },
    );
    if (!credential) throw new NotFoundException('Credential not found');
    if (credential.user.id !== ownerUserId) {
      throw new ForbiddenException('Not your credential');
    }
    if (credential.revokedAt) return credential;

    const active = await this.em.count(Credential, {
      user: ownerUserId,
      revokedAt: null,
    });
    if (active <= 1) {
      throw new ConflictException({
        code: 'last_credential',
        message: 'Cannot revoke your last active credential.',
      });
    }

    credential.revokedAt = new Date();

    if (credential.isPrimary) {
      credential.isPrimary = false;
      const successor = await this.em.findOne(
        Credential,
        {
          user: ownerUserId,
          type: credential.type,
          revokedAt: null,
          id: { $ne: credential.id },
        },
        { orderBy: { createdAt: 'ASC' } },
      );
      if (successor) successor.isPrimary = true;
    }

    await this.em.flush();
    return credential;
  }

  async markUsed(credentialId: string): Promise<void> {
    const credential = await this.em.findOne(Credential, { id: credentialId });
    if (!credential) return;
    credential.lastUsedAt = new Date();
    await this.em.flush();
  }
}
