// Slack Events API webhook. Verifies the signature, ACKs within 3s (Slack's
// hard deadline), and fires-and-forgets into the EC2 runner.
//
// Slack docs:
//   - signing: https://api.slack.com/authentication/verifying-requests-from-slack
//   - events: https://api.slack.com/apis/events-api
//   - app_mention: https://api.slack.com/events/app_mention

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'node:crypto';

export const runtime = 'nodejs';
export const maxDuration = 10;

const SLACK_SIGNING_SECRET = process.env.SLACK_SIGNING_SECRET!;
const SLACK_BOT_TOKEN = process.env.SLACK_BOT_TOKEN!;
const RUNNER_URL = process.env.RUNNER_URL!;
const RUNNER_TOKEN = process.env.RUNNER_SHARED_SECRET!;

// Session state lives in the Slack thread root message itself. The local
// Claude Code session posts the root with a marker like:
//   <!-- kuwboo-session: runId=abc branch=bot/foo repo=pcutting/team_kuwboo cwd=. -->
// When a reply arrives we fetch the thread root and parse the marker.
const SESSION_MARKER = /<!--\s*kuwboo-session:\s*([^>]+?)\s*-->/;

interface SlackEventEnvelope {
  type: 'url_verification' | 'event_callback';
  challenge?: string;
  event?: SlackEvent;
  team_id?: string;
}

interface SlackEvent {
  type: 'app_mention' | 'message';
  user?: string;
  text: string;
  ts: string;
  thread_ts?: string;
  channel: string;
  bot_id?: string;
}

interface SessionRecord {
  runId: string;
  branch: string;
  repo: string;
  cwdHint: string;
}

async function readThreadRoot(channel: string, threadTs: string): Promise<string | null> {
  const url = new URL('https://slack.com/api/conversations.replies');
  url.searchParams.set('channel', channel);
  url.searchParams.set('ts', threadTs);
  url.searchParams.set('limit', '1');
  const res = await fetch(url, {
    headers: { authorization: `Bearer ${SLACK_BOT_TOKEN}` },
  });
  if (!res.ok) return null;
  const data = (await res.json()) as { ok: boolean; messages?: Array<{ text?: string }> };
  if (!data.ok || !data.messages?.length) return null;
  return data.messages[0].text ?? null;
}

function parseSessionMarker(rootText: string | null): SessionRecord | null {
  if (!rootText) return null;
  const match = SESSION_MARKER.exec(rootText);
  if (!match) return null;
  const pairs = match[1].split(/\s+/);
  const parsed: Record<string, string> = {};
  for (const p of pairs) {
    const eq = p.indexOf('=');
    if (eq < 0) continue;
    parsed[p.slice(0, eq)] = p.slice(eq + 1);
  }
  if (!parsed.runId || !parsed.branch || !parsed.repo) return null;
  return {
    runId: parsed.runId,
    branch: parsed.branch,
    repo: parsed.repo,
    cwdHint: parsed.cwd ?? '.',
  };
}

function verifySlackSignature(body: string, timestamp: string, signature: string): boolean {
  if (!timestamp || !signature) return false;
  const ageSec = Math.abs(Date.now() / 1000 - Number(timestamp));
  if (ageSec > 60 * 5) return false;

  const base = `v0:${timestamp}:${body}`;
  const expected =
    'v0=' + crypto.createHmac('sha256', SLACK_SIGNING_SECRET).update(base).digest('hex');

  const a = Buffer.from(expected);
  const b = Buffer.from(signature);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

export async function POST(req: NextRequest) {
  const rawBody = await req.text();
  const ts = req.headers.get('x-slack-request-timestamp') ?? '';
  const sig = req.headers.get('x-slack-signature') ?? '';

  if (!verifySlackSignature(rawBody, ts, sig)) {
    return new NextResponse('invalid signature', { status: 401 });
  }

  const payload = JSON.parse(rawBody) as SlackEventEnvelope;

  if (payload.type === 'url_verification') {
    return NextResponse.json({ challenge: payload.challenge });
  }

  if (payload.type === 'event_callback' && payload.event) {
    const ev = payload.event;

    if (ev.bot_id) return new NextResponse('ok', { status: 200 });

    const threadTs = ev.thread_ts;

    // Root @mention with no thread — friendly help instead of silent ignore
    // so the user knows the bot is alive.
    if (!threadTs) {
      await postSlack(
        ev.channel,
        ev.ts,
        "Hi! I act on *replies inside a thread* that my local Claude Code session has tagged with a session marker. Mention me inside one of those threads to send a message to Phil's running agent.",
      );
      return new NextResponse('ok', { status: 200 });
    }

    const rootText = await readThreadRoot(ev.channel, threadTs);
    const session = parseSessionMarker(rootText);

    if (!session) {
      await postSlack(
        ev.channel,
        threadTs,
        "This thread doesn't have a `<!-- kuwboo-session: ... -->` marker in its root message. Phil's Claude Code session posts those when it's asking for your feedback — reply in *that* thread, not a fresh one.",
      );
      return new NextResponse('ok', { status: 200 });
    }

    // Fire-and-forget dispatch. Do NOT await — Slack needs a 200 within 3 seconds
    // and the EC2 runner may take minutes to finish an agent run.
    fetch(RUNNER_URL, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${RUNNER_TOKEN}`,
      },
      body: JSON.stringify({
        threadTs,
        channel: ev.channel,
        userText: ev.text,
        userId: ev.user,
        session,
      }),
    }).catch((e) => console.error('runner dispatch failed', e));

    return new NextResponse('ok', { status: 200 });
  }

  return new NextResponse('ok', { status: 200 });
}

async function postSlack(channel: string, thread_ts: string, text: string) {
  return fetch('https://slack.com/api/chat.postMessage', {
    method: 'POST',
    headers: {
      'content-type': 'application/json; charset=utf-8',
      authorization: `Bearer ${SLACK_BOT_TOKEN}`,
    },
    // reply_broadcast=true — posts inside the thread AND sends a copy to the
    // channel, so Phil sees bot responses in #claude without drilling into
    // every thread.
    body: JSON.stringify({ channel, thread_ts, text, reply_broadcast: true }),
  });
}
