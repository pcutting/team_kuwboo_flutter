// Pulls credentials from AWS Secrets Manager at boot so they're never on disk
// or in the PM2 env dump. Falls back to process.env for local dev.

import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION ?? 'eu-west-2' });

async function readSecret(name: string): Promise<Record<string, string>> {
  const res = await client.send(new GetSecretValueCommand({ SecretId: name }));
  if (!res.SecretString) throw new Error(`secret ${name} has no SecretString`);
  return JSON.parse(res.SecretString);
}

export interface Secrets {
  slackBotToken: string;
  slackSigningSecret: string;
  anthropicApiKey: string;
  githubPat: string;
  runnerSharedSecret: string;
}

export async function loadSecrets(): Promise<Secrets> {
  if (process.env.LOCAL_DEV === '1') {
    return {
      slackBotToken: must('SLACK_BOT_TOKEN'),
      slackSigningSecret: must('SLACK_SIGNING_SECRET'),
      anthropicApiKey: must('ANTHROPIC_API_KEY'),
      githubPat: must('GITHUB_PAT'),
      runnerSharedSecret: must('RUNNER_SHARED_SECRET'),
    };
  }

  const [slack, anthropic, github, shared] = await Promise.all([
    readSecret('/kuwboo/slack'),
    readSecret('/kuwboo/anthropic'),
    readSecret('/kuwboo/github'),
    readSecret('/kuwboo/slack-runner'),
  ]);

  return {
    slackBotToken: slack.bot_token,
    slackSigningSecret: slack.signing_secret,
    anthropicApiKey: anthropic.api_key,
    githubPat: github.pat,
    runnerSharedSecret: shared.shared_secret,
  };
}

function must(name: string): string {
  const v = process.env[name];
  if (!v) throw new Error(`missing env ${name}`);
  return v;
}
