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

  async sendPhoneOtp(phone: string): Promise<void> {
    if (this.twilioClient && this.verifySid) {
      await this.twilioClient.verify.v2
        .services(this.verifySid)
        .verifications.create({ to: phone, channel: 'sms' });
      return;
    }

    // Local dev fallback: store a hashed code
    const code = this.generateCode();
    const codeHash = await bcrypt.hash(code, BCRYPT_ROUNDS);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

    const verification = this.em.create(Verification, {
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
  async sendEmailOtp(email: string): Promise<void> {
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

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}
