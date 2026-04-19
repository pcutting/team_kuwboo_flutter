import { Module } from '@nestjs/common';

import { EMAIL_PROVIDER } from './email.provider';
import { EmailService } from './email.service';
import { SesEmailProvider } from './ses-email.provider';

/**
 * Global-style wiring for the EmailProvider port.
 *
 * `SesEmailProvider` is registered as the class-provider, AND the
 * `EMAIL_PROVIDER` token is bound to the same singleton via `useExisting`
 * so `EmailService` (which injects the token) and any future consumer
 * that wants the raw provider resolve to the same instance.
 *
 * When the time comes to add a Postmark/Resend/etc. adapter, change the
 * `useExisting` target here (driven by `email.provider` config) rather
 * than touching any consumer code.
 */
@Module({
  providers: [
    SesEmailProvider,
    {
      provide: EMAIL_PROVIDER,
      useExisting: SesEmailProvider,
    },
    EmailService,
  ],
  exports: [EmailService],
})
export class EmailModule {}
