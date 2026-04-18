// Slack Events API webhook. Verifies the signature, ACKs within 3s (Slack's
// hard deadline), and fires-and-forgets into the EC2 runner.
//
// Slack docs:
//   - signing: https://api.slack.com/authentication/verifying-requests-from-slack
//   - events: https://api.slack.com/apis/events-api
//   - app_mention: https://api.slack.com/events/app_mention

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'node:crypto';
import { kv } from '@vercel/kv';

export const runtime = 'nodejs';
export const maxDuration = 10;

const SLACK_SIGNING_SECRET = process.env.SLACK_SIGNING_SECRET!;
const SLACK_BOT_TOKEN = process.env.SLACK_BOT_TOKEN!;
const RUNNER_URL = process.env.RUNNER_URL!;
const RUNNER_TOKEN = process.env.RUNNER_SHARED_SECRET!;

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
    if (!threadTs) {
      return new NextResponse('ignored: not a thread reply', { status: 200 });
    }

    const session = await kv.get<SessionRecord>(`slack:thread:${threadTs}`);

    if (!session) {
      await postSlack(
        ev.channel,
        threadTs,
        "I don't have a session bound to this thread yet. Start one from your Claude Code session first.",
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
    body: JSON.stringify({ channel, thread_ts, text }),
  });
}
