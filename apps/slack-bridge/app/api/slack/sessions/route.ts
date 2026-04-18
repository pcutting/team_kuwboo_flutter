// Session-binding endpoint. Phil's local Claude Code session POSTs here
// immediately after it posts the root "I need your feedback" message to a
// Slack thread, so replies can be routed back to the correct repo branch.
//
// Auth: Bearer <RUNNER_SHARED_SECRET>. Same secret protects the EC2 runner;
// since only Phil's local session and the runner hold it, that's sufficient.

import { NextRequest, NextResponse } from 'next/server';
import { kv } from '@vercel/kv';

export const runtime = 'nodejs';
export const maxDuration = 10;

const RUNNER_TOKEN = process.env.RUNNER_SHARED_SECRET!;
const TTL_SECONDS = 60 * 60 * 24 * 7; // 7 days — stale sessions fall off on their own

interface BindBody {
  threadTs: string;
  runId: string;
  branch: string;
  repo: string;
  cwdHint?: string;
}

export async function POST(req: NextRequest) {
  const auth = req.headers.get('authorization') ?? '';
  if (auth !== `Bearer ${RUNNER_TOKEN}`) {
    return new NextResponse('unauthorized', { status: 401 });
  }

  const body = (await req.json()) as BindBody;
  if (!body.threadTs || !body.runId || !body.branch || !body.repo) {
    return new NextResponse('missing fields', { status: 400 });
  }

  await kv.set(
    `slack:thread:${body.threadTs}`,
    {
      runId: body.runId,
      branch: body.branch,
      repo: body.repo,
      cwdHint: body.cwdHint ?? '.',
    },
    { ex: TTL_SECONDS },
  );

  return NextResponse.json({ ok: true });
}
