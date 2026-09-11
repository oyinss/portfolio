/// Portfolio API (§39): public GET reads published data only (§38).
/// Mutating routes require admin auth (§50); unimplemented ones return 501.
import { Hono } from 'hono';
import { cors } from 'hono/cors';

import { hashPassword, issueToken, requireAdmin, verifyPassword } from './auth';
import { registerAdminRoutes } from './admin';

type Env = {
  DB: D1Database;
  FILES: R2Bucket;
  ALLOWED_ORIGIN?: string;
  ADMIN_TOKEN?: string;
  R2_PUBLIC_URL?: string;
};

const app = new Hono<{ Bindings: Env; Variables: { adminId: string } }>();

app.use('/api/*', async (c, next) => {
  const corsMw = cors({ origin: c.env.ALLOWED_ORIGIN ?? '*' });
  return corsMw(c, next);
});

const parseJson = <T>(raw: string | null, fallback: T): T => {
  try {
    return raw ? (JSON.parse(raw) as T) : fallback;
  } catch {
    return fallback;
  }
};

const bool = (v: number | null) => (v ?? 0) === 1;

app.get('/api/health', (c) => c.json({ ok: true }));

app.get('/', (c) =>
  c.json({
    name: 'portfolio-api',
    docs: [
      'GET /api/health',
      'GET /api/profile',
      'GET /api/projects[?featured=true]',
      'GET /api/projects/:slug',
      'GET /api/skills',
      'GET /api/experience',
      'GET /api/education',
      'GET /api/socials',
      'GET /api/settings',
    ],
  }),
);

app.get('/api/profile', async (c) => {
  const row = await c.env.DB.prepare('SELECT * FROM portfolio_profile WHERE id = 1').first();
  if (!row) return c.json({ error: 'profile not configured' }, 404);
  return c.json({
    name: row.name,
    headline: row.headline,
    title: row.title,
    intro: row.intro,
    bio: row.bio,
    email: row.email,
    phone: row.phone,
    location: row.location,
    availability: row.availability,
    yearsExperience: row.years_experience,
    currentRole: row.current_role,
    interests: parseJson<string[]>(row.interests_json as string | null, []),
    resumeUrl: row.resume_url,
    profileImageUrl: row.profile_image_url,
  });
});

const mapProject = (row: Record<string, unknown>) => ({
  id: row.id,
  title: row.title,
  slug: row.slug,
  shortDescription: row.short_description,
  description: row.description,
  imageUrl: row.image_url,
  liveUrl: row.live_url,
  githubUrl: row.github_url,
  technologies: parseJson<string[]>(row.technologies_json as string | null, []),
  type: row.type,
  featured: bool(row.featured as number | null),
  status: row.status,
  displayOrder: row.display_order,
  dateLabel: row.date_label,
  problem: row.problem,
  solution: row.solution,
  features: parseJson<string[]>(row.features_json as string | null, []),
});

app.get('/api/projects', async (c) => {
  const featuredOnly = c.req.query('featured') === 'true' || c.req.query('featured') === '1';
  const { results } = await c.env.DB.prepare(
    `SELECT * FROM projects WHERE status = 'published'
     ${featuredOnly ? 'AND featured = 1' : ''}
     ORDER BY display_order ASC`,
  ).all();
  return c.json(results.map(mapProject));
});

app.get('/api/projects/:slug', async (c) => {
  const slug = c.req.param('slug');
  const row = await c.env.DB.prepare(
    "SELECT * FROM projects WHERE slug = ? AND status = 'published'",
  )
    .bind(slug)
    .first();
  if (!row) return c.json({ error: 'project not found' }, 404);
  return c.json(mapProject(row as Record<string, unknown>));
});

app.get('/api/skills', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM skills ORDER BY display_order ASC',
  ).all();
  return c.json(results);
});

app.get('/api/experience', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM experience ORDER BY display_order ASC',
  ).all();
  return c.json(
    results.map((r) => ({
      ...r,
      current: bool(r.current as number | null),
      technologies: parseJson<string[]>(r.technologies_json as string | null, []),
    })),
  );
});

app.get('/api/education', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM education ORDER BY display_order ASC',
  ).all();
  return c.json(results);
});

app.get('/api/socials', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT platform, url FROM social_links WHERE enabled = 1 ORDER BY display_order ASC',
  ).all();
  return c.json(results);
});

app.get('/api/settings', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT key, value FROM portfolio_settings').all();
  return c.json(Object.fromEntries(results.map((r) => [r.key, r.value])));
});

// ---- Phase 5 auth (§50) ----
app.post('/api/auth/login', async (c) => {
  const secret = c.env.ADMIN_TOKEN;
  if (!secret) return c.json({ error: 'auth not configured' }, 500);
  const body = (await c.req.json().catch(() => null)) as {
    email?: string;
    password?: string;
  } | null;
  if (!body?.email || !body?.password) {
    return c.json({ error: 'email and password required' }, 400);
  }
  const row = await c.env.DB.prepare('SELECT id, email, password_hash FROM users WHERE email = ?')
    .bind(body.email)
    .first();
  if (!row || !(await verifyPassword(body.password, row.password_hash as string))) {
    return c.json({ error: 'invalid credentials' }, 401);
  }
  return c.json({ token: await issueToken(row.id as string, secret), email: row.email });
});

app.get('/api/auth/me', requireAdmin, async (c) => {
  const row = await c.env.DB.prepare('SELECT id, email FROM users WHERE id = ?')
    .bind(c.get('adminId'))
    .first();
  if (!row) return c.json({ error: 'user not found' }, 401);
  return c.json({ id: row.id, email: row.email });
});

app.post('/api/auth/change-password', requireAdmin, async (c) => {
  const body = (await c.req.json().catch(() => null)) as {
    currentPassword?: string;
    newPassword?: string;
  } | null;
  if (!body?.currentPassword || !body?.newPassword) {
    return c.json({ error: 'currentPassword and newPassword required' }, 400);
  }
  if (body.newPassword.length < 12) {
    return c.json({ error: 'new password must be at least 12 characters' }, 400);
  }
  const row = await c.env.DB.prepare('SELECT id, password_hash FROM users WHERE id = ?')
    .bind(c.get('adminId'))
    .first();
  if (!row) return c.json({ error: 'user not found' }, 401);
  if (!(await verifyPassword(body.currentPassword, row.password_hash as string))) {
    return c.json({ error: 'current password is incorrect' }, 401);
  }
  await c.env.DB.prepare('UPDATE users SET password_hash = ? WHERE id = ?')
    .bind(await hashPassword(body.newPassword), c.get('adminId'))
    .run();
  return c.json({ ok: true });
});

// First real protected write (proves the auth chain; full CRUD lands in Phase 6).
app.put('/api/settings', requireAdmin, async (c) => {
  const body = (await c.req.json().catch(() => null)) as Record<string, unknown> | null;
  const entries = body && typeof body === 'object' ? Object.entries(body) : [];
  if (!entries.length) return c.json({ error: 'provide a settings object' }, 400);
  const stmt = c.env.DB.prepare(
    'INSERT INTO portfolio_settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value',
  );
  await c.env.DB.batch(entries.map(([k, v]) => stmt.bind(k, String(v))));
  return c.json({ ok: true, updated: entries.map(([k]) => k) });
});

// ---- Remaining admin writes live in src/admin.ts (Phase 6) ----
app.post('/api/contact', (c) => c.json({ error: 'contact storage lands in a later release' }, 501));

registerAdminRoutes(app);

export default app;
