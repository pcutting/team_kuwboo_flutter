# team_kuwboo

Kuwboo multi-platform monorepo: Flutter mobile app (iOS + Android), NestJS backend, shared Flutter packages, and two static web frontends. Managed with Melos + pub workspaces (Flutter) and npm (admin).

**Current focus: the Flutter mobile app.** Web and admin are secondary in this phase.

## Apps

| App | Stack | Deploy target | Rendering |
|---|---|---|---|
| `apps/mobile` | Flutter (iOS + Android) | TestFlight via GitHub Actions | Native |
| `apps/api` | NestJS | EC2 (`35.177.230.139`, eu-west-2) | N/A |
| `apps/web` | Flutter web (prototype, 56 screens) | Vercel — `team_kuwboo_flutter` | **Static** — prebuilt `apps/web/build/web` |
| `apps/admin` | React 19 + Vite 6 + Tailwind 4 + react-router 7 | Vercel — `team_kuwboo_admin` | **Static** — client-side SPA (built from source) |

## Deployment architecture

All web hosting is **static**. There is no SSR, no Next.js, no Vercel Functions, no middleware, no edge compute.

- `apps/web` ships as a **pre-built Flutter web bundle** committed under `apps/web/build/web/`. Vercel's build step is empty (`buildCommand: ""` in root `vercel.json`); Vercel just serves the output directory and applies the SPA rewrite.
- `apps/admin` is a **Vite SPA** that Vercel builds from source (`npm run build` → `dist/`) with a SPA rewrite. The Vercel project's root directory is set to `apps/admin`.
- `apps/api` (NestJS) runs on EC2 via PM2 behind Nginx. It is **not** deployed to Vercel.

If a future phase needs server rendering, API routes, middleware, or image optimization, that's a deliberate architectural decision — it's not in the repo today.

## Packages

| Package | Purpose |
|---|---|
| `packages/ui` | Shared Flutter theme + widgets |
| `packages/kuwboo_shell` | Shared app shell (nav, state providers) |
| `packages/kuwboo_screens` | Shared screen implementations (yoyo, video, social, shop, dating) |
| `packages/kuwboo_chat` | Shared chat UI |
| `packages/models` | Shared data models |
| `packages/api_client` | Generated API client |

Both `apps/mobile` and `apps/web` consume these packages via pub path dependencies — the web prototype and mobile app render the same UI code.

## Quick links

- [`CLAUDE.md`](CLAUDE.md) — conventions for AI agents working in this repo (PR rules, no-AI-attribution, iOS signing)
- [`docs/README.md`](docs/README.md) — documentation index
- [`docs/team/internal/TESTFLIGHT_RUNBOOK.md`](docs/team/internal/TESTFLIGHT_RUNBOOK.md) — iOS deployment runbook
- [`docs/team/internal/INFRASTRUCTURE.md`](docs/team/internal/INFRASTRUCTURE.md) — AWS resource inventory

## Common commands

```bash
# Mobile dev
cd apps/mobile && flutter run -d "iPhone 15 Pro"

# Web prototype dev
cd apps/web && flutter run -d web-server --web-port=8087

# Admin dev
cd apps/admin && npm run dev   # http://localhost:5173

# Trigger TestFlight build
gh workflow run ios-testflight.yml --ref main -f environment=prod --repo pcutting/team_kuwboo
```
