import { loadAwsSecrets } from './aws-secrets';

describe('loadAwsSecrets', () => {
  const originalEnv = { ...process.env };

  afterEach(() => {
    process.env = { ...originalEnv };
  });

  it('no-ops when AWS_LOAD_SECRETS is not set', async () => {
    delete process.env.AWS_LOAD_SECRETS;
    delete process.env.FIREBASE_PROJECT_ID;

    await loadAwsSecrets();

    expect(process.env.FIREBASE_PROJECT_ID).toBeUndefined();
  });

  it('no-ops when AWS_LOAD_SECRETS is any value other than "1"', async () => {
    process.env.AWS_LOAD_SECRETS = 'true';
    delete process.env.FIREBASE_PROJECT_ID;

    await loadAwsSecrets();

    expect(process.env.FIREBASE_PROJECT_ID).toBeUndefined();
  });
});
