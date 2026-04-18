// Smoke checks for the runner's external dependencies. Exercises each API the
// runner uses so we find out *before* a real agent run that (say) the
// GitHub PAT expired or the Anthropic key was revoked. The webhook's `status`
// command fans out to this endpoint; a local bash probe hits it too.

import type { FastifyInstance } from 'fastify';
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';
import { execFileSync } from 'node:child_process';
import { statSync } from 'node:fs';
import type { Secrets } from './secrets.js';

interface Check {
  name: string;
  ok: boolean;
  ms: number;
  detail?: string;
  error?: string;
}

interface CheckResult {
  ok: boolean;
  detail?: string;
  error?: string;
}

export function registerSmokeRoute(
  app: FastifyInstance,
  secrets: Secrets,
  agentRunsDir: string,
): void {
  app.get('/smoke', async (req, reply) => {
    const auth = req.headers.authorization ?? '';
    if (auth !== `Bearer ${secrets.runnerSharedSecret}`) {
      return reply.code(401).send({ error: 'unauthorized' });
    }
    const checks = await runChecks(secrets, agentRunsDir);
    const ok = checks.every((c) => c.ok);
    return reply.code(ok ? 200 : 503).send({ ok, checks });
  });
}

async function runChecks(secrets: Secrets, agentRunsDir: string): Promise<Check[]> {
  // Run network checks in parallel — they're all independent.
  return Promise.all([
    timed('slack', () => checkSlack(secrets.slackBotToken)),
    timed('github', () => checkGithub(secrets.githubPat)),
    timed('anthropic', () => checkAnthropic(secrets.anthropicApiKey)),
    timed('secrets_manager', () => checkSecretsManager()),
    timed('agent_runs_dir', () => checkAgentRunsDir(agentRunsDir)),
    timed('gh_cli', () => checkGhCli()),
  ]);
}

async function timed(name: string, fn: () => Promise<CheckResult>): Promise<Check> {
  const t0 = Date.now();
  try {
    const r = await fn();
    return { name, ok: r.ok, ms: Date.now() - t0, detail: r.detail, error: r.error };
  } catch (e) {
    return {
      name,
      ok: false,
      ms: Date.now() - t0,
      error: String((e as Error)?.message ?? e).slice(0, 200),
    };
  }
}

async function checkSlack(token: string): Promise<CheckResult> {
  const res = await fetch('https://slack.com/api/auth.test', {
    method: 'POST',
    headers: { authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(5000),
  });
  const data = (await res.json()) as {
    ok: boolean;
    user?: string;
    team?: string;
    error?: string;
  };
  return {
    ok: data.ok,
    detail: data.ok ? `as ${data.user}@${data.team}` : undefined,
    error: data.ok ? undefined : data.error,
  };
}

async function checkGithub(pat: string): Promise<CheckResult> {
  const res = await fetch('https://api.github.com/user', {
    headers: {
      authorization: `token ${pat}`,
      'user-agent': 'kuwboo-slack-runner-smoke',
      accept: 'application/vnd.github+json',
    },
    signal: AbortSignal.timeout(5000),
  });
  if (!res.ok) return { ok: false, error: `http ${res.status}` };
  const data = (await res.json()) as { login: string };
  return { ok: true, detail: `as ${data.login}` };
}

async function checkAnthropic(apiKey: string): Promise<CheckResult> {
  // /v1/models is a cheap auth check — no tokens are billed for listing.
  const res = await fetch('https://api.anthropic.com/v1/models', {
    headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01' },
    signal: AbortSignal.timeout(5000),
  });
  if (!res.ok) return { ok: false, error: `http ${res.status}` };
  const data = (await res.json()) as { data: Array<{ id: string }> };
  return { ok: true, detail: `${data.data.length} models` };
}

async function checkSecretsManager(): Promise<CheckResult> {
  const client = new SecretsManagerClient({
    region: process.env.AWS_REGION ?? 'eu-west-2',
  });
  const res = await client.send(
    new GetSecretValueCommand({ SecretId: '/kuwboo/slack-runner' }),
  );
  return { ok: !!res.SecretString, detail: res.SecretString ? 'reachable' : undefined };
}

async function checkAgentRunsDir(dir: string): Promise<CheckResult> {
  const s = statSync(dir);
  if (!s.isDirectory()) return { ok: false, error: 'not a directory' };
  return { ok: true, detail: dir };
}

async function checkGhCli(): Promise<CheckResult> {
  const out = execFileSync('gh', ['--version'], { encoding: 'utf8' }).trim();
  // "gh version 2.67.0 (2025-...)" — grab just the version number.
  const m = out.match(/gh version (\S+)/);
  return { ok: true, detail: m?.[1] ?? out.slice(0, 40) };
}
