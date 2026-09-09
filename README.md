# Portfolio CMS — Flutter + Cloudflare

A self-hosted, customizable developer portfolio CMS. Clone it, deploy it,
configure it from the admin dashboard — no code edits needed after deployment.

## Features

**Public portfolio**

- Home (hero, stats, featured projects), About, Projects + per-project
  case-study routes (`/projects/:slug`), Skills, Experience, Education, Contact
- Responsive: sidebar (desktop) → rail (tablet) → drawer (mobile)
- Light / Dark / System + Blue / Purple / Emerald accents; owner defaults with
  per-visitor browser overrides
- Section visibility + ordering, draft projects, featured projects
- Per-route document titles, meta/OG tags, `robots.txt`, `sitemap.xml`

**Admin dashboard** (`/admin`)

- Token-auth login, guarded routes
- Profile editor (incl. photo + resume upload to R2)
- Project CRUD with auto-unique slugs and screenshot upload (client-side
  resize/compress)
- Skills / Experience / Education / Social links CRUD
- Appearance (default theme, sections, order) and site settings

## Architecture

```text
Flutter Web (app/) ──API──▶ Cloudflare Worker (workers/)
                               ├─▶ D1 (database)
                               └─▶ R2 (files)
```

Public API is read-only published data; all writes require admin auth.

## Installation

Requirements: Flutter 3.x, Node 18+, a Cloudflare account, `wrangler`
(`npm install -g wrangler`).

```sh
git clone <your-fork> && cd portfolio
wrangler login
```

## Cloudflare setup

```sh
wrangler d1 create portfolio-db        # paste database_id into workers/wrangler.toml
wrangler r2 bucket create portfolio-files
```

Optional (gives uploaded files public URLs): Dashboard → R2 →
`portfolio-files` → Custom Domain, then set `R2_PUBLIC_URL` in
`workers/wrangler.toml`. Without it, uploads still work but return storage keys.

## Environment variables

Worker (`workers/wrangler.toml` / secrets):

| Variable         | Where                        | Purpose                              |
| ---------------- | ---------------------------- | ------------------------------------ |
| `database_id`    | `wrangler.toml`              | D1 database id                       |
| `R2_PUBLIC_URL`  | `wrangler.toml` `[vars]`     | Public base URL for uploaded files   |
| `ALLOWED_ORIGIN` | `wrangler.toml` `[vars]`     | CORS origin (`*` for dev)            |
| `ADMIN_TOKEN`    | `wrangler secret put`        | HMAC key for admin session tokens    |

Flutter (build time):

| Variable  | Purpose                                              |
| --------- | ---------------------------------------------------- |
| `API_URL` | Worker URL; empty = offline mock mode for local dev |

## Database setup

```sh
cd workers
npm install
npm run migrate:remote          # schema + seed data
node scripts/create-admin.mjs you@example.com "strong-password-123"
# paste the printed INSERT into:
wrangler d1 execute portfolio-db --remote --file <(node scripts/create-admin.mjs you@example.com "pw")
```

## Deployment

```sh
# API
cd workers && npm run deploy

# Web (Cloudflare Pages)
cd app && flutter build web --release --dart-define=API_URL=https://<worker>.<subdomain>.workers.dev
npx wrangler pages deploy build/web --project-name portfolio-web
```

Then visit `/admin` on the Pages URL, sign in, and configure everything.

## Local development

```sh
cd workers && npx wrangler dev --local --port 8787   # API + local D1/R2
cd app && ./run-web.sh                               # Flutter on :8091 (live API)
```

## Database workflow (local-first)

Develop against the **local** D1 database. The live database is only touched
by `migrate:remote` during a deploy — never hand-edit it, and never run
`d1 execute --remote --file` with a destructive script.

```sh
cd workers
npm run migrate:local    # develop here: schema + guarded seeds, safe to re-run
npm run deploy:safe      # migrate:remote (no-op unless new migrations) + deploy
```

Rules for every new migration file (`migrations/NNNN_*.sql`):

- Never `DELETE FROM <table>` without a `WHERE` that matches only seed rows.
- Personal/seed rows use `INSERT ... ON CONFLICT (...) DO NOTHING`.
- Profile changes only fill placeholder/empty rows — owner edits via `/admin`
  always win. See `0004_your_data.sql` for the pattern.

## Customization

- New accent: add a seed color to `AccentTheme` (`app/lib/core/theme/`)
- New section: add a key to `defaultSectionOrder` (`core/config/site_config.dart`),
  a nav item, route, page, and migration seed row
- Tokens (`AppTokens`) centralize every color — no hard-coded colors in widgets

## Contributing

Keep public reads open, writes authed; add a migration for schema changes;
mirror seed changes in `app/lib/core/data/mock_portfolio.dart` so mock mode
stays faithful.
