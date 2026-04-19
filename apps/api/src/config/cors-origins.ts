// Single source of truth for allowed CORS origins across the NestJS HTTP
// server and every Socket.io gateway. Production permits the kuwboo.com
// subdomains plus any localhost port (reachable only from the developer's
// own machine, so it doesn't widen the external attack surface); non-prod
// also lets the Vercel default host through so preview URLs work end-to-end.
export const corsOrigins = (
  env: NodeJS.ProcessEnv = process.env,
): (string | RegExp)[] => {
  const prodHosts = [
    'https://kuwboo.com',
    'https://www.kuwboo.com',
    'https://app.kuwboo.com',
    'https://admin.kuwboo.com',
  ];
  const localhost = /^http:\/\/localhost(:\d+)?$/;
  if (env.NODE_ENV === 'production') return [...prodHosts, localhost];
  return [
    ...prodHosts,
    localhost,
    // Vercel default hostnames used for preview deployments — lets the
    // in-browser app talk to a locally-running dev backend.
    /^https:\/\/[^./]+\.vercel\.app$/,
  ];
};
