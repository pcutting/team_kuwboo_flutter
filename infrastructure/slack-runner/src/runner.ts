// EC2 runner: receives dispatches from the Vercel Slack bridge, clones the
// repo into a per-run workdir, runs the Claude Agent SDK, commits, pushes,
// and opens a PR. Reports progress + the final PR URL back to the Slack
// thread.
//
// Deployed as a standalone PM2 process (port 4100) isolated from the main
// kuwboo-api so an agent crash can't take down the real API.
//
// Docs:
//   Claude Agent SDK: https://docs.claude.com/en/api/agent-sdk
//   Slack chat.postMessage: https://api.slack.com/methods/chat.postMessage

import Fastify from 'fastify';
import { query } from '@anthropic-ai/claude-agent-sdk';
import { execFileSync } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';
import { z } from 'zod';

import { loadSecrets } from './secrets.js';
import { makeSlackClient } from './slack.js';
import { registerSmokeRoute } from './smoke.js';

const PORT = Number(process.env.RUNNER_PORT ?? 4100);
const AGENT_RUNS_DIR = process.env.AGENT_RUNS_DIR ?? '/home/ubuntu/agent-runs';

const dispatchSchema = z.object({
  threadTs: z.string(),
  channel: z.string(),
  userText: z.string(),
  userId: z.string().optional(),
  session: z.object({
    runId: z.string(),
    branch: z.string(),
    repo: z.string(),
    cwdHint: z.string().default('.'),
  }),
});
type DispatchBody = z.infer<typeof dispatchSchema>;

async function main() {
  const secrets = await loadSecrets();
  const slack = makeSlackClient(secrets.slackBotToken);

  // Expose the Anthropic key for the Agent SDK's internal provider.
  process.env.ANTHROPIC_API_KEY = secrets.anthropicApiKey;

  const app = Fastify({ logger: true });

  app.post('/internal/agent-runs', async (req, reply) => {
    const auth = req.headers.authorization ?? '';
    if (auth !== `Bearer ${secrets.runnerSharedSecret}`) {
      return reply.code(401).send({ error: 'unauthorized' });
    }

    const parsed = dispatchSchema.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({ error: 'invalid body', issues: parsed.error.issues });
    }
    const body = parsed.data;

    // ACK fast — Vercel's dispatch is fire-and-forget, but we still want a
    // quick 202 so the call doesn't time out on the Vercel side.
    reply.code(202).send({ accepted: true, runId: body.session.runId });

    runAgent(body, secrets.githubPat, slack).catch(async (err) => {
      app.log.error({ err }, 'agent run crashed');
      await slack
        .postMessage(body.channel, body.threadTs, `Runner crashed: \`${String(err?.message ?? err).slice(0, 500)}\``)
        .catch((slackErr) => app.log.error({ slackErr }, 'failed to notify slack about crash'));
    });
  });

  app.get('/healthz', async () => ({ ok: true, port: PORT }));
  registerSmokeRoute(app, secrets, AGENT_RUNS_DIR);

  await app.listen({ host: '0.0.0.0', port: PORT });
  app.log.info({ port: PORT }, 'kuwboo-slack-runner ready');
}

async function runAgent(
  body: DispatchBody,
  githubPat: string,
  slack: ReturnType<typeof makeSlackClient>,
) {
  const { threadTs, channel, userText, session } = body;
  const shortId = randomUUID().slice(0, 8);
  const workdir = path.join(AGENT_RUNS_DIR, `${session.runId}-${shortId}`);
  mkdirSync(workdir, { recursive: true });

  const remote = `https://x-access-token:${githubPat}@github.com/${session.repo}.git`;

  await slack.postMessage(
    channel,
    threadTs,
    `Picked it up. Working in branch \`${session.branch}\`…`,
  );

  // 1. Clone + ensure branch exists
  run('git', ['clone', '--depth=50', remote, workdir]);
  run('git', ['-C', workdir, 'config', 'user.email', 'bot@kuwboo.dev']);
  run('git', ['-C', workdir, 'config', 'user.name', 'kuwboo-agent-bot']);

  try {
    run('git', ['-C', workdir, 'fetch', 'origin', session.branch]);
    run('git', ['-C', workdir, 'checkout', '-t', `origin/${session.branch}`]);
  } catch {
    run('git', ['-C', workdir, 'checkout', '-b', session.branch]);
  }

  // 2. Run the Agent SDK
  const prompt = [
    `You are continuing an in-progress Kuwboo agent session.`,
    `Repo root: ${workdir}`,
    `Starting point inside repo: ${session.cwdHint}`,
    ``,
    `User instruction from Slack:`,
    userText,
    ``,
    `When done, write a ≤ 200-word summary of what you changed and why.`,
    `Do NOT commit — the harness will commit and open the PR for you.`,
  ].join('\n');

  let finalText = '';
  for await (const msg of query({
    prompt,
    options: {
      cwd: path.join(workdir, session.cwdHint || '.'),
      permissionMode: 'acceptEdits',
      allowedTools: ['Read', 'Write', 'Edit', 'Glob', 'Grep', 'Bash'],
    },
  })) {
    if (msg.type === 'assistant') {
      const parts = (msg.message.content ?? []) as Array<{ type: string; text?: string }>;
      const textPart = parts
        .filter((p) => p.type === 'text')
        .map((p) => p.text ?? '')
        .join('\n');
      if (textPart) finalText = textPart;
    }
  }

  // 3. Commit + push (if anything changed)
  run('git', ['-C', workdir, 'add', '-A']);
  const dirtyExit = safeRun('git', ['-C', workdir, 'diff', '--cached', '--quiet']);
  if (dirtyExit === 0) {
    await slack.postMessage(
      channel,
      threadTs,
      `Agent finished without code changes.\n\n${finalText.slice(0, 2500)}`,
    );
    return;
  }

  run('git', ['-C', workdir, 'commit', '-m', `agent: ${userText.slice(0, 60)}`]);
  run('git', ['-C', workdir, 'push', '-u', 'origin', session.branch]);

  // 4. Open or update the PR. Do NOT auto-merge — policy is stop-at-PR.
  const prUrl = ensurePr(workdir, session.repo, session.branch, userText);

  // 5. Report back
  await slack.postMessage(
    channel,
    threadTs,
    `Done → ${prUrl}\n\n${finalText.slice(0, 2500)}`,
  );
  await slack.addReaction(channel, threadTs, 'white_check_mark');
}

function run(cmd: string, args: string[]): void {
  execFileSync(cmd, args, { stdio: 'pipe', env: process.env });
}

function safeRun(cmd: string, args: string[]): number {
  try {
    execFileSync(cmd, args, { stdio: 'pipe', env: process.env });
    return 0;
  } catch (err) {
    const e = err as { status?: number };
    return e.status ?? 1;
  }
}

function ensurePr(cwd: string, repo: string, branch: string, title: string): string {
  try {
    const existing = execFileSync(
      'gh',
      ['-R', repo, 'pr', 'view', branch, '--json', 'url', '-q', '.url'],
      { cwd, encoding: 'utf8' },
    ).trim();
    if (existing) return existing;
  } catch {
    // fall through to create
  }
  return execFileSync(
    'gh',
    [
      '-R',
      repo,
      'pr',
      'create',
      '--base',
      'main',
      '--head',
      branch,
      '--title',
      `agent: ${title.slice(0, 60)}`,
      '--body',
      `Opened by kuwboo-slack-runner on behalf of Phil.\n\nTrigger:\n> ${title}\n\n**Not auto-merging — human review required.**`,
    ],
    { cwd, encoding: 'utf8' },
  ).trim();
}

main().catch((err) => {
  console.error('runner failed to start', err);
  process.exit(1);
});
