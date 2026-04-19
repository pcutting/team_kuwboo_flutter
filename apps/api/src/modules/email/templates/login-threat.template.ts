/**
 * Login threat notice template.
 *
 * Sent when the brute-force detector (issue #174 follow-up) flags
 * suspicious login activity — repeated failures, geo-impossible attempts,
 * unusual user agent. The body must be informational only: we do NOT
 * include a one-click "yes / no, it wasn't me" link here because this
 * template can be delivered to inboxes we do not control, and any such
 * token would be phishable. The user is directed back to the app to
 * review sessions and, if needed, change their password.
 */

import type { RenderedEmail } from './otp.template';

export interface LoginThreatTemplateContext {
  /** Source IP of the suspicious attempts. */
  ipAddress: string;
  /** Best-effort device / browser string. */
  userAgent: string;
  /** Count of failed attempts in the trailing 24h window. */
  attemptsLast24h: number;
}

export function renderLoginThreatEmail(
  ctx: LoginThreatTemplateContext,
): RenderedEmail {
  const subject = 'Suspicious login activity on your Kuwboo account';

  const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${subject}</title>
</head>
<body style="margin:0;padding:0;background:#f6f7f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#111;">
  <div style="max-width:600px;margin:0 auto;padding:32px 24px;">
    <h1 style="font-size:20px;font-weight:600;margin:0 0 16px;">${subject}</h1>
    <p style="font-size:15px;line-height:1.5;margin:0 0 20px;">We noticed a series of failed sign-in attempts on your Kuwboo account. If this was you, you can ignore this email.</p>
    <div style="background:#fff;border:1px solid #e1e4e8;border-radius:8px;padding:16px 20px;margin:0 0 20px;font-size:13px;line-height:1.6;">
      <div><strong>Attempts in the last 24 hours:</strong> ${ctx.attemptsLast24h}</div>
      <div><strong>IP address:</strong> ${ctx.ipAddress}</div>
      <div><strong>Device:</strong> ${ctx.userAgent}</div>
    </div>
    <p style="font-size:15px;line-height:1.5;margin:0 0 20px;">If this wasn't you, open Kuwboo, review your active sessions, and change your password. We've temporarily throttled new sign-in attempts from this IP.</p>
    <p style="font-size:13px;color:#57606a;margin:0;">This is an automated security notice. Please do not reply.</p>
  </div>
</body>
</html>`;

  const text = [
    subject,
    '',
    'We noticed a series of failed sign-in attempts on your Kuwboo account. If this was you, you can ignore this email.',
    '',
    `Attempts in the last 24 hours: ${ctx.attemptsLast24h}`,
    `IP address: ${ctx.ipAddress}`,
    `Device: ${ctx.userAgent}`,
    '',
    "If this wasn't you, open Kuwboo, review your active sessions, and change your password. We've temporarily throttled new sign-in attempts from this IP.",
    '',
    'This is an automated security notice. Please do not reply.',
  ].join('\n');

  return { subject, html, text };
}
