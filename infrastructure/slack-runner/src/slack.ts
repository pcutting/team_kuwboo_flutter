// Thin wrappers for the Slack Web API calls we need — postMessage + reactions.

export function makeSlackClient(botToken: string) {
  async function postMessage(
    channel: string,
    threadTs: string,
    text: string,
    options: { broadcast?: boolean } = {},
  ): Promise<void> {
    const res = await fetch('https://slack.com/api/chat.postMessage', {
      method: 'POST',
      headers: {
        'content-type': 'application/json; charset=utf-8',
        authorization: `Bearer ${botToken}`,
      },
      // reply_broadcast defaults to true: thread replies are also mirrored to
      // the channel so Phil sees them without drilling into every thread.
      body: JSON.stringify({
        channel,
        thread_ts: threadTs,
        text,
        reply_broadcast: options.broadcast ?? true,
      }),
    });
    if (!res.ok) throw new Error(`slack postMessage ${res.status}: ${await res.text()}`);
  }

  async function addReaction(channel: string, timestamp: string, name: string): Promise<void> {
    const res = await fetch('https://slack.com/api/reactions.add', {
      method: 'POST',
      headers: {
        'content-type': 'application/json; charset=utf-8',
        authorization: `Bearer ${botToken}`,
      },
      body: JSON.stringify({ channel, timestamp, name }),
    });
    if (!res.ok) throw new Error(`slack reactions.add ${res.status}: ${await res.text()}`);
  }

  return { postMessage, addReaction };
}
