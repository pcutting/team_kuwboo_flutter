// Single source of truth for allowed CORS origins across the NestJS HTTP
// server and every Socket.io gateway. Production permits only the kuwboo.com
// subdomains; non-production additionally allows any localhost port for
// local dev.
export const corsOrigins = (
  env: NodeJS.ProcessEnv = process.env,
): (string | RegExp)[] => {
  const prod = [
    'https://kuwboo.com',
    'https://www.kuwboo.com',
    'https://app.kuwboo.com',
    'https://admin.kuwboo.com',
  ];
  if (env.NODE_ENV === 'production') return prod;
  return [...prod, /^http:\/\/localhost(:\d+)?$/];
};
