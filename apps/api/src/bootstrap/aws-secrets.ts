import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from '@aws-sdk/client-secrets-manager';

/**
 * Mapping from `/kuwboo/<secret>` JSON fields to `process.env` keys.
 *
 * Order matters for readability only — each secret is fetched in parallel.
 */
const SECRET_MAPPINGS: ReadonlyArray<{
  secretId: string;
  fields: Record<string, string>;
}> = [
  {
    secretId: '/kuwboo/firebase',
    fields: {
      project_id: 'FIREBASE_PROJECT_ID',
      client_email: 'FIREBASE_CLIENT_EMAIL',
      private_key: 'FIREBASE_PRIVATE_KEY',
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
    SECRET_MAPPINGS.map(async ({ secretId, fields }) => {
      const out = await client.send(
        new GetSecretValueCommand({ SecretId: secretId }),
      );
      if (!out.SecretString) {
        throw new Error(`Secret ${secretId} has no SecretString payload`);
      }
      const parsed = JSON.parse(out.SecretString) as Record<string, string>;
      let applied = 0;
      for (const [jsonKey, envKey] of Object.entries(fields)) {
        if (process.env[envKey]) continue; // respect caller override
        const value = parsed[jsonKey];
        if (typeof value !== 'string') continue;
        process.env[envKey] = value;
        applied += 1;
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
