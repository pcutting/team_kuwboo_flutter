import { registerAs } from '@nestjs/config';

/**
 * Transactional email configuration.
 *
 * `provider` is a discriminator for future provider swaps. Today only
 * `ses` is implemented; the value is recorded here so the wiring in
 * `EmailModule` can switch on it without the consumers noticing.
 *
 * `defaultFrom` is the From address every transactional email uses unless
 * a caller explicitly overrides it. Must be an SES-verified identity when
 * using the SES adapter in production.
 *
 * SES credentials: in production these come from AWS Secrets Manager
 * (`/kuwboo/smtp`) via `apps/api/src/bootstrap/aws-secrets.ts`. Leave the
 * env vars blank in local dev to fall through to the default AWS
 * credential chain (or simply not hit SES — EmailService never calls the
 * adapter unless someone upstream asks it to).
 */
export default registerAs('email', () => ({
  provider: process.env.EMAIL_PROVIDER_NAME || 'ses',
  defaultFrom: process.env.EMAIL_DEFAULT_FROM || 'hello@kuwboo.com',
  sesRegion: process.env.SES_REGION || 'eu-west-1',
  sesAccessKeyId: process.env.SES_ACCESS_KEY_ID || '',
  sesSecretAccessKey: process.env.SES_SECRET_ACCESS_KEY || '',
}));
