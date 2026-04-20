import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { BullModule } from '@nestjs/bullmq';
import { User } from './entities/user.entity';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import { AccountAnonymizeProcessor } from './workers/account-anonymize.processor';
import { ACCOUNT_ANONYMIZE_QUEUE } from './workers/account-anonymize.queue';
import { SessionsModule } from '../sessions/sessions.module';
import { AdminAuditLog } from '../admin/entities/admin-audit-log.entity';
import { AdminAuditService } from '../admin/admin-audit.service';
import { FreshTokenGuard } from '../../common/guards/fresh-token.guard';

/**
 * Account-lifecycle module — kept separate from UsersModule to avoid
 * a circular dependency chain that would otherwise form:
 *
 *   UsersModule -> SessionsModule -> RealtimeModule ->
 *     MessagingModule -> UsersModule.
 *
 * MessagingModule depends on UsersModule directly (not via a
 * forwardRef), so we can't close that loop just by adding a
 * `forwardRef(() => SessionsModule)` on UsersModule — the cycle
 * persists because MessagingModule's dependency has to resolve
 * non-lazily.
 *
 * Putting the AccountController / AccountService / BullMQ processor
 * in a peer module that imports both UsersModule and SessionsModule
 * lets AccountService pull SessionsService without tangling the
 * UsersModule dependency graph.
 *
 * AdminAuditService is provided directly here (not via AdminModule)
 * because AdminModule imports ContentModule which in turn imports
 * UsersModule — keeping the AdminModule import out of this tree keeps
 * the dependency graph flat.
 */
@Module({
  imports: [
    MikroOrmModule.forFeature([User, AdminAuditLog]),
    BullModule.registerQueue({ name: ACCOUNT_ANONYMIZE_QUEUE }),
    SessionsModule,
  ],
  controllers: [AccountController],
  providers: [
    AccountService,
    AdminAuditService,
    FreshTokenGuard,
    AccountAnonymizeProcessor,
  ],
})
export class AccountModule {}
