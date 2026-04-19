/**
 * Password-reset link template.
 *
 * Distinct from the OTP template because the reset flow may use a signed
 * magic-link URL instead of (or in addition to) a short numeric code.
 * The URL must appear in both the HTML call-to-action button and the
 * plain-text body so non-HTML clients can still use it.
 */

import type { RenderedEmail } from './otp.template';

export interface PasswordResetTemplateContext {
  /** Fully-qualified URL the user must click to complete the reset. */
  resetUrl: string;
  /** Minutes until the link expires. Optional — omit to skip the line. */
  expiresInMinutes?: number;
}

export function renderPasswordResetEmail(
  ctx: PasswordResetTemplateContext,
): RenderedEmail {
  const subject = 'Reset your Kuwboo password';
  const expiryLine =
    typeof ctx.expiresInMinutes === 'number'
      ? `This link expires in ${ctx.expiresInMinutes} minutes.`
      : '';

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
    <p style="font-size:15px;line-height:1.5;margin:0 0 20px;">Click the button below to choose a new password. If you didn't request a reset, you can ignore this email and your password will stay the same.</p>
    <p style="margin:0 0 24px;">
      <a href="${ctx.resetUrl}" style="display:inline-block;background:#111;color:#fff;padding:12px 20px;border-radius:6px;text-decoration:none;font-weight:600;font-size:15px;">Reset password</a>
    </p>
    <p style="font-size:13px;color:#57606a;margin:0 0 8px;">Or copy and paste this link into your browser:</p>
    <p style="font-size:13px;word-break:break-all;margin:0 0 20px;"><a href="${ctx.resetUrl}" style="color:#0a66c2;">${ctx.resetUrl}</a></p>
    ${expiryLine ? `<p style="font-size:13px;color:#57606a;margin:0;">${expiryLine}</p>` : ''}
  </div>
</body>
</html>`;

  const textLines = [
    subject,
    '',
    "Click the link below to choose a new password. If you didn't request a reset, you can ignore this email.",
    '',
    ctx.resetUrl,
    '',
  ];
  if (expiryLine) textLines.push(expiryLine);

  return {
    subject,
    html,
    text: textLines.join('\n'),
  };
}
