import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';

import { EmailService } from './email.service';
import {
  EMAIL_PROVIDER,
  EmailProvider,
  SendTransactionalEmailRequest,
  SendTransactionalEmailResult,
} from './email.provider';

/**
 * Unit tests for EmailService.
 *
 * Strategy: inject a stub `EmailProvider` that records every call and
 * returns a canned result. Verifies that (a) the service delegates to the
 * port exactly once per send, (b) the rendered body carries the
 * purpose-specific content, and (c) headers/from fall back to config.
 */
describe('EmailService', () => {
  const DEFAULT_FROM = 'test-sender@kuwboo.com';

  let service: EmailService;
  let provider: jest.Mocked<EmailProvider>;
  let sentRequests: SendTransactionalEmailRequest[];

  beforeEach(async () => {
    sentRequests = [];
    provider = {
      sendTransactional: jest.fn(
        async (req): Promise<SendTransactionalEmailResult> => {
          sentRequests.push(req);
          return { messageId: 'stub-message-id', providerName: 'stub' };
        },
      ),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EmailService,
        { provide: EMAIL_PROVIDER, useValue: provider },
        {
          provide: ConfigService,
          useValue: {
            get: (key: string) => {
              if (key === 'email.defaultFrom') return DEFAULT_FROM;
              return undefined;
            },
          },
        },
      ],
    }).compile();

    service = module.get(EmailService);
  });

  describe('sendOtp', () => {
    it('renders the OTP template and calls the provider exactly once', async () => {
      const result = await service.sendOtp({
        to: 'user@example.com',
        code: '123456',
        purpose: 'login',
        expiresInMinutes: 10,
      });

      expect(provider.sendTransactional).toHaveBeenCalledTimes(1);
      expect(result.messageId).toBe('stub-message-id');

      const [req] = sentRequests;
      expect(req.to).toBe('user@example.com');
      expect(req.from).toBe(DEFAULT_FROM);
      expect(req.subject).toContain('login');
      // Code must appear in both bodies so clients that render only one
      // still work.
      expect(req.html).toContain('123456');
      expect(req.text).toContain('123456');
    });

    it('includes the purpose in the subject for password-reset', async () => {
      await service.sendOtp({
        to: 'user@example.com',
        code: '654321',
        purpose: 'password-reset',
      });
      const [req] = sentRequests;
      expect(req.subject).toContain('password-reset');
    });

    it('includes the purpose in the subject for verify-email', async () => {
      await service.sendOtp({
        to: 'user@example.com',
        code: '111111',
        purpose: 'verify-email',
      });
      const [req] = sentRequests;
      expect(req.subject).toContain('verify-email');
    });
  });

  describe('sendPasswordResetLink', () => {
    it('includes the URL in both HTML and text bodies', async () => {
      const url = 'https://kuwboo.com/reset?token=abc.def.ghi';
      await service.sendPasswordResetLink({
        to: 'user@example.com',
        resetUrl: url,
        expiresInMinutes: 30,
      });

      expect(provider.sendTransactional).toHaveBeenCalledTimes(1);
      const [req] = sentRequests;
      expect(req.html).toContain(url);
      expect(req.text).toContain(url);
      expect(req.from).toBe(DEFAULT_FROM);
    });
  });

  describe('sendLoginThreatNotice', () => {
    it('includes the IP, user agent, and attempt count in both bodies', async () => {
      await service.sendLoginThreatNotice({
        to: 'user@example.com',
        ipAddress: '203.0.113.7',
        userAgent: 'Mozilla/5.0 (TestRunner)',
        attemptsLast24h: 12,
      });

      expect(provider.sendTransactional).toHaveBeenCalledTimes(1);
      const [req] = sentRequests;
      expect(req.html).toContain('203.0.113.7');
      expect(req.text).toContain('203.0.113.7');
      expect(req.html).toContain('Mozilla/5.0 (TestRunner)');
      expect(req.text).toContain('Mozilla/5.0 (TestRunner)');
      expect(req.html).toContain('12');
      expect(req.text).toContain('12');
    });
  });

  describe('defaultFrom fallback', () => {
    it('falls back to hello@kuwboo.com when config is missing', async () => {
      const module: TestingModule = await Test.createTestingModule({
        providers: [
          EmailService,
          { provide: EMAIL_PROVIDER, useValue: provider },
          {
            provide: ConfigService,
            useValue: { get: () => undefined },
          },
        ],
      }).compile();

      const fallbackService = module.get(EmailService);
      await fallbackService.sendOtp({
        to: 'user@example.com',
        code: '999999',
        purpose: 'login',
      });

      const lastReq = sentRequests[sentRequests.length - 1];
      expect(lastReq.from).toBe('hello@kuwboo.com');
    });
  });
});
