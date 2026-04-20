import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from '@aws-sdk/client-secrets-manager';

/**
 * Mapping from `/kuwboo/<secret>` JSON fields to `process.env` keys.
 *
 * Order matters for readability only — each secret is fetched in parallel.
 */
/**
 * Two payload shapes are supported:
 *   - `fields`: the secret's SecretString is a JSON object; each (jsonKey →
 *     envKey) pair pulls one field out into process.env. Used by /kuwboo/firebase.
 *   - `envKey` (with no `fields`): the secret's SecretString is the raw value
 *     itself, written to a single env var. Used by /kuwboo/apple/* — each
 *     scalar lives in its own secret because that's what scripts/sso/
 *     generate_apple_client_secret.py upserts.
 */
type SecretMapping =
  | { secretId: string; fields: Record<string, string>; envKey?: never }
  | { secretId: string; envKey: string; fields?: never };

const SECRET_MAPPINGS: ReadonlyArray<SecretMapping> = [
  {
    secretId: '/kuwboo/firebase',
    fields: {
      project_id: 'FIREBASE_PROJECT_ID',
      client_email: 'FIREBASE_CLIENT_EMAIL',
      private_key: 'FIREBASE_PRIVATE_KEY',
    },
  },
  // Apple Sign In — five scalar secrets minted by
  // scripts/sso/generate_apple_client_secret.py
  { secretId: '/kuwboo/apple/team-id', envKey: 'APPLE_TEAM_ID' },
  { secretId: '/kuwboo/apple/services-id', envKey: 'APPLE_SERVICE_ID' },
  { secretId: '/kuwboo/apple/key-id', envKey: 'APPLE_KEY_ID' },
  { secretId: '/kuwboo/apple/private-key', envKey: 'APPLE_PRIVATE_KEY' },
  { secretId: '/kuwboo/apple/client-secret-jwt', envKey: 'APPLE_CLIENT_SECRET' },
  // SES credentials for the EmailModule (apps/api/src/modules/email).
  // The secret JSON is {"accessKeyId":"...","secretAccessKey":"..."}; we
  // fan it out to the SES_* env vars the email.config registerAs reads.
  {
    secretId: '/kuwboo/smtp',
    fields: {
      accessKeyId: 'SES_ACCESS_KEY_ID',
      secretAccessKey: 'SES_SECRET_ACCESS_KEY',
    },
  },
  // Media pipeline: S3 bucket + CloudFront domain consumed by
  // apps/api/src/modules/media/providers/s3.provider.ts. JSON keys already
  // match the env-var names, so the mapping is an identity.
  {
    secretId: '/kuwboo/media',
    fields: {
      AWS_S3_BUCKET: 'AWS_S3_BUCKET',
      AWS_CLOUDFRONT_DOMAIN: 'AWS_CLOUDFRONT_DOMAIN',
    },
  },
  // Future: /kuwboo/database, /kuwboo/redis, /kuwboo/jwt can join here
  // once the NestJS config modules are migrated off env-var-per-setting.
];

/**
 * Load AWS Secrets Manager secrets into `process.env` before NestJS boots.
 *
 * Gated by `AWS_LOAD_SECRETS=1`. On EC2 with an attached IAM role this works
 * with no AWS credential configuration. Locally, the caller must have AWS
 * credentials in the environment / `~/.aws/credentials` and should leave the
 * flag off (falling through to `.env`) unless deliberately testing the path.
 *
 * Behaviour:
 * - If the flag is off, no-op (returns immediately, no SDK instantiation).
 * - If a secret is missing from Secrets Manager, logs a warning and
 *   continues — the service using it will fall through to its existing
 *   "disabled" path (e.g. `NotificationsService` without FCM config).
 * - Existing `process.env` values win over Secrets Manager values. Lets a
 *   developer override a single key locally without taking down the whole
 *   secret.
 */
export async function loadAwsSecrets(): Promise<void> {
  if (process.env.AWS_LOAD_SECRETS !== '1') {
    return;
  }

  const region =
    process.env.AWS_REGION ??
    process.env.AWS_DEFAULT_REGION ??
    'eu-west-2';
  const client = new SecretsManagerClient({ region });

  const results = await Promise.allSettled(
    SECRET_MAPPINGS.map(async (mapping) => {
      const { secretId } = mapping;
      const out = await client.send(
        new GetSecretValueCommand({ SecretId: secretId }),
      );
      if (!out.SecretString) {
        throw new Error(`Secret ${secretId} has no SecretString payload`);
      }
      let applied = 0;
      if ('envKey' in mapping && mapping.envKey) {
        // Raw-scalar secret — the SecretString is the value itself.
        if (!process.env[mapping.envKey]) {
          process.env[mapping.envKey] = out.SecretString;
          applied = 1;
        }
      } else if (mapping.fields) {
        // JSON-object secret — pluck named fields.
        const parsed = JSON.parse(out.SecretString) as Record<string, string>;
        for (const [jsonKey, envKey] of Object.entries(mapping.fields)) {
          if (process.env[envKey]) continue; // respect caller override
          const value = parsed[jsonKey];
          if (typeof value !== 'string') continue;
          process.env[envKey] = value;
          applied += 1;
        }
      }
      return { secretId, applied };
    }),
  );

  for (const [idx, r] of results.entries()) {
    const { secretId } = SECRET_MAPPINGS[idx];
    if (r.status === 'fulfilled') {
      // eslint-disable-next-line no-console
      console.log(
        `[aws-secrets] ${secretId}: ${r.value.applied} env var(s) loaded`,
      );
    } else {
      // eslint-disable-next-line no-console
      console.warn(
        `[aws-secrets] ${secretId}: failed (${(r.reason as Error).message}) — service will fall back to local config`,
      );
    }
  }

  client.destroy();
}
