import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { SESv2Client, SendEmailCommand } from '@aws-sdk/client-sesv2';
import { mockClient } from 'aws-sdk-client-mock';

import { SesEmailProvider } from './ses-email.provider';
import {
  EmailSendError,
  SendTransactionalEmailRequest,
} from './email.provider';

/**
 * Unit tests for SesEmailProvider.
 *
 * Strategy: mock the SESv2Client at the SDK level with `aws-sdk-client-mock`
 * so the provider's `send()` call is intercepted. That lets us assert
 * the exact `SendEmailCommand` input (matching the SESv2 Content.Simple
 * shape) without network IO or real AWS credentials.
 */
describe('SesEmailProvider', () => {
  const sesMock = mockClient(SESv2Client);

  const fixtureRequest: SendTransactionalEmailRequest = {
    to: 'user@example.com',
    from: 'hello@kuwboo.com',
    subject: 'Hello',
    html: '<p>hello</p>',
    text: 'hello',
    replyTo: 'noreply@kuwboo.com',
    headers: { 'X-Entity-Ref-Id': 'abc-123' },
  };

  async function buildProvider(
    overrides: Record<string, string> = {},
  ): Promise<SesEmailProvider> {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SesEmailProvider,
        {
          provide: ConfigService,
          useValue: {
            get: (key: string) => overrides[key],
          },
        },
      ],
    }).compile();
    return module.get(SesEmailProvider);
  }

  beforeEach(() => {
    sesMock.reset();
  });

  it('calls SendEmailCommand with the SESv2 Content.Simple envelope', async () => {
    sesMock.on(SendEmailCommand).resolves({ MessageId: 'ses-msg-1' });

    const provider = await buildProvider({
      'email.sesRegion': 'eu-west-1',
    });

    const result = await provider.sendTransactional(fixtureRequest);

    expect(result).toEqual({
      messageId: 'ses-msg-1',
      providerName: 'ses',
    });

    const calls = sesMock.commandCalls(SendEmailCommand);
    expect(calls).toHaveLength(1);

    const input = calls[0].args[0].input;
    expect(input.FromEmailAddress).toBe('hello@kuwboo.com');
    expect(input.Destination?.ToAddresses).toEqual(['user@example.com']);
    expect(input.ReplyToAddresses).toEqual(['noreply@kuwboo.com']);

    const simple = input.Content?.Simple;
    expect(simple?.Subject?.Data).toBe('Hello');
    expect(simple?.Body?.Html?.Data).toBe('<p>hello</p>');
    expect(simple?.Body?.Text?.Data).toBe('hello');
    expect(simple?.Headers).toEqual([
      { Name: 'X-Entity-Ref-Id', Value: 'abc-123' },
    ]);
  });

  it('returns the MessageId surfaced by the mock response', async () => {
    sesMock.on(SendEmailCommand).resolves({ MessageId: 'ses-msg-2' });

    const provider = await buildProvider();
    const result = await provider.sendTransactional({
      to: 'a@b.com',
      from: 'c@d.com',
      subject: 's',
      html: 'h',
      text: 't',
    });

    expect(result.messageId).toBe('ses-msg-2');
    expect(result.providerName).toBe('ses');
  });

  it('throws EmailSendError when SES rejects the command', async () => {
    sesMock
      .on(SendEmailCommand)
      .rejects(new Error('MessageRejected: address is on suppression list'));

    const provider = await buildProvider();

    await expect(provider.sendTransactional(fixtureRequest)).rejects.toBeInstanceOf(
      EmailSendError,
    );
  });

  it('throws EmailSendError when SES accepts but returns no MessageId', async () => {
    sesMock.on(SendEmailCommand).resolves({});

    const provider = await buildProvider();

    await expect(provider.sendTransactional(fixtureRequest)).rejects.toBeInstanceOf(
      EmailSendError,
    );
  });
});
