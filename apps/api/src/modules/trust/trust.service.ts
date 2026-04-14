import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { TrustSignal } from './entities/trust-signal.entity';
import { User } from '../users/entities/user.entity';
import { TrustSignalType } from '../../common/enums';

export interface AppendSignalInput {
  userId: string;
  type: TrustSignalType | string;
  delta: number;
  source?: string;
  metadata?: Record<string, unknown>;
  expiresAt?: Date;
}

/**
 * Trust signal authoring. All rows are append-only; a user's current
 * trust_score is derived via sum(delta) over active rows. The score cache
 * denormalisation (users.trust_score) is updated by TRUST_ENGINE's decay
 * worker — outside D1a scope. Here we only append.
 */
@Injectable()
export class TrustService {
  constructor(private readonly em: EntityManager) {}

  async append(input: AppendSignalInput): Promise<TrustSignal> {
    const user = this.em.getReference(User, input.userId);
    const signal = this.em.create(TrustSignal, {
      user,
      signalType: typeof input.type === 'string' ? input.type : input.type,
      delta: input.delta,
      source: input.source,
      metadata: input.metadata,
      expiresAt: input.expiresAt,
    } as any);
    await this.em.flush();
    return signal;
  }
}
