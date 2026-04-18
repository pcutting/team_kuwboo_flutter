export const metadata = {
  title: 'Kuwboo Slack Bridge',
  description: 'Webhook-only deployment for the Slack ↔ Claude Agent SDK relay.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
