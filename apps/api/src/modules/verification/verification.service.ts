import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EntityManager } from '@mikro-orm/postgresql';
import * as bcrypt from 'bcrypt';
import { Verification } from './entities/verification.entity';
import { VerificationType } from '../../common/enums';

const OTP_LENGTH = 6;
const OTP_EXPIRY_MINUTES = 10;
const MAX_ATTEMPTS = 5;
const BCRYPT_ROUNDS = 10;

@Injectable()
export class VerificationService {
  private readonly twilioClient: any;
  private readonly verifySid: string;

  constructor(
    private readonly em: EntityManager,
    private readonly config: ConfigService,
  ) {
    const accountSid = this.config.get<string>('TWILIO_ACCOUNT_SID');
    const authToken = this.config.get<string>('TWILIO_AUTH_TOKEN');
    this.verifySid = this.config.get<string>('TWILIO_VERIFY_SERVICE_SID') || '';

    if (accountSid && authToken) {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const twilio = require('twilio');
      this.twilioClient = twilio(accountSid, authToken);
    }
  }

  async sendPhoneOtp(phone: string): Promise<{ devCode?: string }> {
    if (this.twilioClient && this.verifySid) {
      await this.twilioClient.verify.v2
        .services(this.verifySid)
        .verifications.create({ to: phone, channel: 'sms' });
      return {};
    }

    // Local dev fallback: store a hashed code
    const code = this.generateCode();
    const codeHash = await bcrypt.hash(code, BCRYPT_ROUNDS);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

    this.em.create(Verification, {
      identifier: phone,
      codeHash,
      type: VerificationType.PHONE_OTP,
      expiresAt,
    } as any);

    await this.em.flush();

    // Log code in development only
    if (this.config.get('NODE_ENV') === 'development') {
      console.log(`[DEV] OTP for ${phone}: ${code}`);
    }

    // Return the plaintext code in non-production environments so the mobile
    // client can render it in the on-screen OTP banner. In production (or
    // when Twilio is configured above), this branch is never taken.
    if (process.env.NODE_ENV !== 'production') {
      return { devCode: code };
    }
    return {};
  }

  async verifyPhoneOtp(phone: string, code: string): Promise<boolean> {
    if (this.twilioClient && this.verifySid) {
      const check = await this.twilioClient.verify.v2
        .services(this.verifySid)
        .verificationChecks.create({ to: phone, code });
      return check.status === 'approved';
    }

    // Local dev fallback: check stored code
    const verification = await this.em.findOne(
      Verification,
      {
        identifier: phone,
        type: VerificationType.PHONE_OTP,
        verifiedAt: null,
        expiresAt: { $gt: new Date() },
      },
      { orderBy: { createdAt: 'DESC' } },
    );

    if (!verification) {
      throw new BadRequestException('No pending verification found');
    }

    if (verification.attempts >= MAX_ATTEMPTS) {
      throw new UnauthorizedException('Too many attempts. Request a new code.');
    }

    // Run bcrypt compare FIRST. Only increment attempts on failure so a
    // network blip or 5xx during verify doesn't consume an attempt for a code
    // the user actually entered correctly (or never got to validate).
    const isValid = await bcrypt.compare(code, verification.codeHash);
    if (isValid) {
      verification.verifiedAt = new Date();
      await this.em.flush();
      return true;
    }

    verification.attempts += 1;
    await this.em.flush();
    throw new UnauthorizedException('Invalid code');
  }

  /**
   * Email OTP. Uses the same `verifications` table as phone OTP with
   * `type=EMAIL_VERIFY`. Email is normalised by the caller (lowercased,
   * dot-stripped for Gmail) before reaching this method.
   *
   * Third-party integration (AWS SES) is stubbed here: if
   * SES_EMAIL_ENABLED=1 and an SES client is wired, send; otherwise the
   * dev fallback logs the code to stdout. A clean seam for D3's
   * EmailTransport service is left as a TODO.
   */
  async sendEmailOtp(email: string): Promise<{ devCode?: string }> {
    const code = this.generateCode();
    const codeHash = await bcrypt.hash(code, BCRYPT_ROUNDS);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

    this.em.create(Verification, {
      identifier: email,
      codeHash,
      type: VerificationType.EMAIL_VERIFY,
      expiresAt,
    } as any);
    await this.em.flush();

    // TODO(D3): replace with SES transport once the infra is wired.
    if (this.config.get('NODE_ENV') !== 'production') {
      console.log(`[DEV] Email OTP for ${email}: ${code}`);
    }

    // Return the plaintext code in non-production environments so the mobile
    // client can render it in the on-screen OTP banner. Email OTP has no
    // Twilio branch — the local-fallback is the only path until SES lands —
    // so gating purely on NODE_ENV is sufficient.
    if (process.env.NODE_ENV !== 'production') {
      return { devCode: code };
    }
    return {};
  }

  async verifyEmailOtp(email: string, code: string): Promise<boolean> {
    const verification = await this.em.findOne(
      Verification,
      {
        identifier: email,
        type: VerificationType.EMAIL_VERIFY,
        verifiedAt: null,
        expiresAt: { $gt: new Date() },
      },
      { orderBy: { createdAt: 'DESC' } },
    );

    if (!verification) {
      throw new BadRequestException({
        code: 'invalid_otp',
        message: 'No pending verification found',
      });
    }

    if (verification.attempts >= MAX_ATTEMPTS) {
      throw new UnauthorizedException({
        code: 'invalid_otp',
        message: 'Too many attempts. Request a new code.',
      });
    }

    // Same fix as verifyPhoneOtp: only bump attempts on actual failure.
    const isValid = await bcrypt.compare(code, verification.codeHash);
    if (isValid) {
      verification.verifiedAt = new Date();
      await this.em.flush();
      return true;
    }

    verification.attempts += 1;
    await this.em.flush();
    throw new UnauthorizedException({
      code: 'invalid_otp',
      message: 'Invalid code',
    });
  }

  /**
   * Password-reset OTP. Shares the `verifications` table with email OTP
   * but uses the `PASSWORD_RESET` discriminator so the two code streams
   * cannot be confused and each is consumed exactly once.
   */
  async sendPasswordResetOtp(email: string): Promise<{ devCode?: string }> {
    const code = this.generateCode();
    const codeHash = await bcrypt.hash(code, BCRYPT_ROUNDS);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 15);

    this.em.create(Verification, {
      identifier: email,
      codeHash,
      type: VerificationType.PASSWORD_RESET,
      expiresAt,
    } as any);
    await this.em.flush();

    if (this.config.get('NODE_ENV') !== 'production') {
      console.log(`[DEV] Password reset OTP for ${email}: ${code}`);
      return { devCode: code };
    }
    return {};
  }

  /**
   * Validates a PASSWORD_RESET code. Succeeds silently; callers that need
   * the verified row back can rely on `verifiedAt` being populated.
   * Throws the same `invalid_code` shape regardless of whether the code
   * was missing, expired, or simply wrong — the reset endpoint must not
   * leak which branch failed.
   */
  async verifyPasswordResetOtp(email: string, code: string): Promise<void> {
    const verification = await this.em.findOne(
      Verification,
      {
        identifier: email,
        type: VerificationType.PASSWORD_RESET,
        verifiedAt: null,
        expiresAt: { $gt: new Date() },
      },
      { orderBy: { createdAt: 'DESC' } },
    );

    if (!verification) {
      throw new BadRequestException({
        code: 'invalid_code',
        message: 'Invalid or expired code.',
      });
    }

    if (verification.attempts >= MAX_ATTEMPTS) {
      throw new BadRequestException({
        code: 'invalid_code',
        message: 'Invalid or expired code.',
      });
    }

    const isValid = await bcrypt.compare(code, verification.codeHash);
    if (!isValid) {
      verification.attempts += 1;
      await this.em.flush();
      throw new BadRequestException({
        code: 'invalid_code',
        message: 'Invalid or expired code.',
      });
    }

    verification.verifiedAt = new Date();
    await this.em.flush();
  }

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}
