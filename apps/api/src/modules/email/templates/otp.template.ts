/**
 * OTP email template.
 *
 * A six-digit (or other short) verification code is the hero content. We
 * do NOT rely on clickable links here: many email clients strip query
 * strings or prefetch URLs, so the user must copy the code manually.
 *
 * HTML is a single-column ~600px max-width layout with inline styles.
 * Text version is equivalent — many users (Outlook with images off,
 * automation pipelines) never render the HTML.
 */

export type OtpPurpose = 'login' | 'password-reset' | 'verify-email';

export interface OtpTemplateContext {
  code: string;
  purpose: OtpPurpose;
  /** Minutes until the code expires. Optional — omit to skip the line. */
  expiresInMinutes?: number;
}

export interface RenderedEmail {
  subject: string;
  html: string;
  text: string;
}

const PURPOSE_COPY: Record<
  OtpPurpose,
  { subject: string; action: string }
> = {
  login: {
    subject: 'Your Kuwboo login code',
    action: 'sign in to your Kuwboo account',
  },
  'password-reset': {
    subject: 'Your Kuwboo password reset code',
    action: 'reset your Kuwboo password',
  },
  'verify-email': {
    subject: 'Verify your email for Kuwboo',
    action: 'verify your email address',
  },
};

export function renderOtpEmail(ctx: OtpTemplateContext): RenderedEmail {
  const copy = PURPOSE_COPY[ctx.purpose];
  const expiryLine =
    typeof ctx.expiresInMinutes === 'number'
      ? `This code expires in ${ctx.expiresInMinutes} minutes.`
      : '';

  const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${copy.subject}</title>
</head>
<body style="margin:0;padding:0;background:#f6f7f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#111;">
  <div style="max-width:600px;margin:0 auto;padding:32px 24px;">
    <h1 style="font-size:20px;font-weight:600;margin:0 0 16px;">${copy.subject}</h1>
    <p style="font-size:15px;line-height:1.5;margin:0 0 20px;">Use the code below to ${copy.action}.</p>
    <div style="background:#fff;border:1px solid #e1e4e8;border-radius:8px;padding:24px;text-align:center;margin:0 0 20px;">
      <div style="font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,monospace;font-size:32px;letter-spacing:6px;font-weight:600;">${ctx.code}</div>
    </div>
    ${expiryLine ? `<p style="font-size:13px;color:#57606a;margin:0 0 12px;">${expiryLine}</p>` : ''}
    <p style="font-size:13px;color:#57606a;margin:0;">If you didn't request this, you can safely ignore this email.</p>
  </div>
</body>
</html>`;

  const textLines = [
    copy.subject,
    '',
    `Use the code below to ${copy.action}.`,
    '',
    `    ${ctx.code}`,
    '',
  ];
  if (expiryLine) textLines.push(expiryLine, '');
  textLines.push("If you didn't request this, you can safely ignore this email.");

  return {
    subject: `${copy.subject} (${ctx.purpose})`,
    html,
    text: textLines.join('\n'),
  };
}
