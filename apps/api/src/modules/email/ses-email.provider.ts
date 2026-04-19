import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SESv2Client, SendEmailCommand } from '@aws-sdk/client-sesv2';

import {
  EmailProvider,
  EmailSendError,
  SendTransactionalEmailRequest,
  SendTransactionalEmailResult,
} from './email.provider';

const PROVIDER_NAME = 'ses';

/**
 * Amazon SES v2 adapter for the `EmailProvider` port.
 *
 * Why SESv2 (not v1)?
 *   - The v1 SES client is in maintenance mode and the message shape is
 *     awkward (separate ToAddresses / Subject / Body). v2 exposes a single
 *     `Content.Simple` (or `Raw`) envelope and is actively developed.
 *
 * Credentials & region:
 *   - Region defaults to `eu-west-1` (SES is not available in eu-west-2).
 *   - Explicit access keys are read from `email.sesAccessKeyId` /
 *     `email.sesSecretAccessKey` when set. If both are empty, the SDK's
 *     default credential chain runs (IAM role on EC2, env vars, shared
 *     credentials file) — the production path.
 *
 * Error contract:
 *   - Any upstream failure is re-thrown as `EmailSendError` so callers
 *     have one exception class to handle regardless of the active adapter.
 */
@Injectable()
export class SesEmailProvider implements EmailProvider {
  private readonly logger = new Logger(SesEmailProvider.name);
  private readonly client: SESv2Client;

  constructor(private readonly config: ConfigService) {
    const region =
      this.config.get<string>('email.sesRegion') || 'eu-west-1';
    const accessKeyId =
      this.config.get<string>('email.sesAccessKeyId') || '';
    const secretAccessKey =
      this.config.get<string>('email.sesSecretAccessKey') || '';

    this.client = new SESv2Client({
      region,
      // If both explicit credentials are provided, pass them through.
      // Otherwise let the default provider chain resolve them (IAM role,
      // env vars, shared credentials file) — the production path.
      ...(accessKeyId && secretAccessKey
        ? { credentials: { accessKeyId, secretAccessKey } }
        : {}),
    });
  }

  async sendTransactional(
    request: SendTransactionalEmailRequest,
  ): Promise<SendTransactionalEmailResult> {
    const command = new SendEmailCommand({
      FromEmailAddress: request.from,
      Destination: { ToAddresses: [request.to] },
      ReplyToAddresses: request.replyTo ? [request.replyTo] : undefined,
      Content: {
        Simple: {
          Subject: { Data: request.subject, Charset: 'UTF-8' },
          Body: {
            Html: { Data: request.html, Charset: 'UTF-8' },
            Text: { Data: request.text, Charset: 'UTF-8' },
          },
          Headers: request.headers
            ? Object.entries(request.headers).map(([Name, Value]) => ({
                Name,
                Value,
              }))
            : undefined,
        },
      },
    });

    try {
      const out = await this.client.send(command);
      if (!out.MessageId) {
        throw new EmailSendError(
          'SES accepted the message but returned no MessageId',
          PROVIDER_NAME,
        );
      }
      return { messageId: out.MessageId, providerName: PROVIDER_NAME };
    } catch (err) {
      if (err instanceof EmailSendError) throw err;
      const message = err instanceof Error ? err.message : 'unknown error';
      this.logger.warn(`SES SendEmailCommand failed: ${message}`);
      throw new EmailSendError(
        `SES send failed: ${message}`,
        PROVIDER_NAME,
        err,
      );
    }
  }
}
