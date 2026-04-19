import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import {
  EMAIL_PROVIDER,
  EmailProvider,
  SendTransactionalEmailResult,
} from './email.provider';
import {
  renderOtpEmail,
  type OtpPurpose,
} from './templates/otp.template';
import { renderPasswordResetEmail } from './templates/password-reset.template';
import { renderLoginThreatEmail } from './templates/login-threat.template';

/**
 * Public NestJS-injectable facade over the configured `EmailProvider`.
 *
 * Consumers call purpose-specific methods (sendOtp, sendPasswordResetLink,
 * sendLoginThreatNotice). The service renders the matching template and
 * delegates to whichever adapter is wired — today SES, tomorrow Postmark
 * or Resend — without the caller needing to know or care.
 */
@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly defaultFrom: string;

  constructor(
    @Inject(EMAIL_PROVIDER) private readonly provider: EmailProvider,
    private readonly config: ConfigService,
  ) {
    this.defaultFrom =
      this.config.get<string>('email.defaultFrom') ||
      'hello@kuwboo.com';
  }

  /**
   * Deliver a one-time code for login, password-reset, or email-verify
   * flows. `purpose` drives the subject line and body copy.
   */
  async sendOtp(args: {
    to: string;
    code: string;
    purpose: OtpPurpose;
    expiresInMinutes?: number;
  }): Promise<SendTransactionalEmailResult> {
    const rendered = renderOtpEmail({
      code: args.code,
      purpose: args.purpose,
      expiresInMinutes: args.expiresInMinutes,
    });

    return this.provider.sendTransactional({
      to: args.to,
      from: this.defaultFrom,
      subject: rendered.subject,
      html: rendered.html,
      text: rendered.text,
    });
  }

  /**
   * Deliver a password-reset link. The URL must be a fully-qualified,
   * signed magic-link produced by the caller (auth / password-reset flow).
   * This method has no opinion on URL format.
   */
  async sendPasswordResetLink(args: {
    to: string;
    resetUrl: string;
    expiresInMinutes?: number;
  }): Promise<SendTransactionalEmailResult> {
    const rendered = renderPasswordResetEmail({
      resetUrl: args.resetUrl,
      expiresInMinutes: args.expiresInMinutes,
    });

    return this.provider.sendTransactional({
      to: args.to,
      from: this.defaultFrom,
      subject: rendered.subject,
      html: rendered.html,
      text: rendered.text,
    });
  }

  /**
   * Security notice for brute-force / suspicious-login events — issue #174
   * follow-up. The signature is defined now so consumers can be wired
   * against it in a follow-up PR without blocking on this module.
   */
  async sendLoginThreatNotice(args: {
    to: string;
    ipAddress: string;
    userAgent: string;
    attemptsLast24h: number;
  }): Promise<SendTransactionalEmailResult> {
    const rendered = renderLoginThreatEmail({
      ipAddress: args.ipAddress,
      userAgent: args.userAgent,
      attemptsLast24h: args.attemptsLast24h,
    });

    return this.provider.sendTransactional({
      to: args.to,
      from: this.defaultFrom,
      subject: rendered.subject,
      html: rendered.html,
      text: rendered.text,
    });
  }
}
