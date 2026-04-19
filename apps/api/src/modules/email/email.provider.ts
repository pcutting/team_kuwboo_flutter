/**
 * Port (interface) for transactional email delivery.
 *
 * The module is structured around this port so swapping from SES to another
 * provider (Postmark, Resend, SendGrid, etc.) is a configuration change,
 * not a code change. Each adapter implements this interface; `EmailService`
 * is wired to exactly one adapter at boot via the `EMAIL_PROVIDER`
 * injection token.
 *
 * Implementations must be stateless with respect to a single send — the
 * service may batch or fan out concurrent calls.
 */

/**
 * DTO passed from `EmailService` to the provider. Kept deliberately small
 * and provider-agnostic; anything a specific backend needs beyond this
 * (e.g. SES ConfigurationSet, Postmark MessageStream) lives in the adapter
 * and is read from config there.
 */
export interface SendTransactionalEmailRequest {
  /** RFC-5322 address. Must already be validated / normalised by the caller. */
  to: string;
  /** RFC-5322 address or `Display Name <addr@example.com>`. */
  from: string;
  /** Subject line, plain text. */
  subject: string;
  /** HTML body. Required — every template produces both html and text. */
  html: string;
  /** Plain-text body. Required — many clients display only text. */
  text: string;
  /** Optional Reply-To header. */
  replyTo?: string;
  /** Optional additional headers (e.g. `X-Entity-Ref-Id` for idempotency). */
  headers?: Record<string, string>;
}

/**
 * Normalised result returned regardless of provider. `messageId` is whatever
 * identifier the provider returns for the accepted message — useful for
 * correlating delivery logs to application logs. `providerName` lets the
 * application log or emit metrics tagged by backend.
 */
export interface SendTransactionalEmailResult {
  messageId: string;
  providerName: string;
}

/**
 * DI token bound to the concrete adapter in `EmailModule`. Consumers that
 * need provider-level access (rare — normally you want `EmailService`) can
 * inject this token.
 */
export const EMAIL_PROVIDER = Symbol('EMAIL_PROVIDER');

/**
 * The port. Each adapter implements `sendTransactional` and throws
 * `EmailSendError` on any upstream failure so callers can handle a single
 * failure type regardless of which provider is wired.
 */
export interface EmailProvider {
  sendTransactional(
    request: SendTransactionalEmailRequest,
  ): Promise<SendTransactionalEmailResult>;
}

/**
 * Typed error thrown by adapters when the upstream provider rejects or
 * fails to deliver the message. Callers above `EmailService` should rarely
 * handle this directly — the service logs and swallows at the right layer
 * so a send failure never leaks "user doesn't exist" through a different
 * HTTP status code on auth endpoints.
 */
export class EmailSendError extends Error {
  constructor(
    message: string,
    public readonly providerName: string,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = 'EmailSendError';
  }
}
