/// Phase 6: protected admin CRUD + R2 uploads (§§20–28, §52).
/// Every route here sits behind `requireAdmin` (Phase 5 token auth).
/* eslint-disable */
// @ts-ignore: ambient worker runtime types (provided by wrangler)
/// <reference types="@cloudflare/workers-types" />
import type { Context } from 'hono';
import { Hono } from 'hono';

import { requireAdmin } from './auth';

type Env = {
  DB: D1Database;
  FILES: R2Bucket;
  ALLOWED_ORIGIN?: string;
  ADMIN_TOKEN?: string;
  R2_PUBLIC_URL?: string;
};

type App = Hono<{ Bindings: Env; Variables: { adminId: string } }>;

const now = () => new Date().toISOString();
const uid = () => crypto.randomUUID();
const str = (v: unknown, fallback = '') => (v == null ? fallback : String(v));
const intFlag = (v: unknown) => (v === true || v === 1 || v === '1' ? 1 : 0);
const json = (v: unknown) => JSON.stringify(v ?? []);

const slugify = (s: string) =>
  s.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'item';

async function uniqueSlug(
  db: D1Database,
  table: string,
  base: string,
  excludeId?: string,
): Promise<string> {
  let slug = slugify(base);
  let n = 2;
  for (;;) {
    const row = await db
      .prepare(`SELECT id FROM ${table} WHERE slug = ?`)
      .bind(slug)
      .first<{ id: string }>();
    if (!row || (excludeId && row.id === excludeId)) return slug;
    slug = `${slugify(base)}-${n++}`;
  }
}

async function body(c: Context): Promise<Record<string, unknown>> {
  const parsed = (await c.req.json().catch(() => null)) as Record<string, unknown> | null;
  if (!parsed || typeof parsed !== 'object') throw new HttpError(400, 'provide a JSON object');
  return parsed;
}

class HttpError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

function wrap(fn: (c: Context) => Promise<Response>) {
  return async (c: Context) => {
    try {
      return await fn(c);
    } catch (e) {
      if (e instanceof HttpError) return c.json({ error: e.message }, e.status as 400);
      throw e;
    }
  };
}

async function notFoundIfMissing(res: D1Result, c: Context, what: string) {
  if (res.meta.changes === 0) return c.json({ error: `${what} not found` }, 404);
  return null;
}

// ---------- projects ----------
const projectFields = (b: Record<string, unknown>) => ({
  title: str(b.title),
  short_description: str(b.shortDescription ?? b.short_description),
  description: str(b.description),
  image_url: b.imageUrl ?? b.image_url ?? null,
  live_url: b.liveUrl ?? b.live_url ?? null,
  github_url: b.githubUrl ?? b.github_url ?? null,
  technologies_json: json(b.technologies),
  type: str(b.type),
  featured: intFlag(b.featured),
  status: b.status === 'published' ? 'published' : 'draft',
  display_order: Number(b.displayOrder ?? b.display_order ?? 0) || 0,
  date_label: str(b.dateLabel ?? b.date_label),
  problem: str(b.problem),
  solution: str(b.solution),
  features_json: json(b.features),
});

// ---------- generic CRUD helper for simple tables ----------
function crud(
  app: App,
  base: string,
  table: string,
  opts: {
    required?: string[];
    map: (b: Record<string, unknown>) => Record<string, unknown>;
  },
) {
  app.post(
    base,
    requireAdmin,
    wrap(async (c) => {
      const b = await body(c);
      for (const f of opts.required ?? []) {
        if (!b[f]) throw new HttpError(400, `${f} is required`);
      }
      const id = uid();
      const fields = opts.map(b);
      const cols = ['id', ...Object.keys(fields)];
      const placeholders = cols.map(() => '?').join(', ');
      await c.env.DB.prepare(`INSERT INTO ${table} (${cols.join(', ')}) VALUES (${placeholders})`)
        .bind(id, ...Object.values(fields))
        .run();
      const row = await c.env.DB.prepare(`SELECT * FROM ${table} WHERE id = ?`).bind(id).first();
      return c.json(row, 201);
    }),
  );

  app.put(
    `${base}/:id`,
    requireAdmin,
    wrap(async (c) => {
      const b = await body(c);
      const id = c.req.param('id');
      const fields = opts.map(b);
      if (!Object.keys(fields).length) throw new HttpError(400, 'nothing to update');
      const sets = Object.keys(fields).map((k) => `${k} = ?`).join(', ');
      const res = await c.env.DB.prepare(`UPDATE ${table} SET ${sets} WHERE id = ?`)
        .bind(...Object.values(fields), id)
        .run();
      const missing = await notFoundIfMissing(res, c, 'record');
      if (missing) return missing;
      return c.json(await c.env.DB.prepare(`SELECT * FROM ${table} WHERE id = ?`).bind(id).first());
    }),
  );

  app.delete(
    `${base}/:id`,
    requireAdmin,
    wrap(async (c) => {
      const id = c.req.param('id');
      const res = await c.env.DB.prepare(`DELETE FROM ${table} WHERE id = ?`).bind(id).run();
      const missing = await notFoundIfMissing(res, c, 'record');
      if (missing) return missing;
      return c.json({ ok: true, id });
    }),
  );
}

export function registerAdminRoutes(app: App) {
  // ----- full project list for the dashboard (drafts included) -----
  app.get('/api/admin/projects', requireAdmin, async (c) => {
    const { results } = await c.env.DB.prepare(
      'SELECT * FROM projects ORDER BY display_order ASC',
    ).all();
    return c.json(results);
  });

  // ----- full social list (incl. disabled) -----
  app.get('/api/admin/socials', requireAdmin, async (c) => {
    const { results } = await c.env.DB.prepare(
      'SELECT * FROM social_links ORDER BY display_order ASC',
    ).all();
    return c.json(results);
  });

  // ----- projects (custom: slug handling) -----
  app.post(
    '/api/projects',
    requireAdmin,
    wrap(async (c) => {
      const b = await body(c);
      if (!b.title) throw new HttpError(400, 'title is required');
      const id = uid();
      const slug = await uniqueSlug(c.env.DB, 'projects', str(b.slug || (b.title as string)));
      const f = projectFields(b);
      await c.env.DB.prepare(
        `INSERT INTO projects (id, title, slug, short_description, description, image_url,
          live_url, github_url, technologies_json, type, featured, status, display_order,
          date_label, problem, solution, features_json, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ${"'" + now() + "'"}, ${"'" + now() + "'"})
         `.replace(/\s+/g, ' '),
      )
        .bind(
          id, f.title, slug, f.short_description, f.description, f.image_url, f.live_url,
          f.github_url, f.technologies_json, f.type, f.featured, f.status, f.display_order,
          f.date_label, f.problem, f.solution, f.features_json,
        )
        .run();
      return c.json(await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(id).first(), 201);
    }),
  );

  app.put(
    '/api/projects/:id',
    requireAdmin,
    wrap(async (c) => {
      const b = await body(c);
      const id = c.req.param('id');
      const existing = await c.env.DB.prepare('SELECT slug FROM projects WHERE id = ?').bind(id).first();
      if (!existing) return c.json({ error: 'project not found' }, 404);
      const slug =
        b.slug != null && b.slug !== ''
          ? await uniqueSlug(c.env.DB, 'projects', str(b.slug), id)
          : existing.slug;
      const f = projectFields({ ...b, slug });
      await c.env.DB.prepare(
        `UPDATE projects SET title = ?, slug = ?, short_description = ?, description = ?,
          image_url = ?, live_url = ?, github_url = ?, technologies_json = ?, type = ?,
          featured = ?, status = ?, display_order = ?, date_label = ?, problem = ?,
          solution = ?, features_json = ?, updated_at = ? WHERE id = ?`.replace(/\s+/g, ' '),
      )
        .bind(
          f.title, slug, f.short_description, f.description, f.image_url, f.live_url,
          f.github_url, f.technologies_json, f.type, f.featured, f.status, f.display_order,
          f.date_label, f.problem, f.solution, f.features_json, now(), id,
        )
        .run();
      return c.json(await c.env.DB.prepare('SELECT * FROM projects WHERE id = ?').bind(id).first());
    }),
  );

  app.delete(
    '/api/projects/:id',
    requireAdmin,
    wrap(async (c) => {
      const id = c.req.param('id');
      const res = await c.env.DB.prepare('DELETE FROM projects WHERE id = ?').bind(id).run();
      const missing = await notFoundIfMissing(res, c, 'project');
      if (missing) return missing;
      return c.json({ ok: true, id });
    }),
  );

  // ----- public file proxy (R2 without custom domain) -----
  app.get('/api/files/:key{.+}', async (c) => {
    const key = c.req.param('key');
    const object = await c.env.FILES.get(key);
    if (!object) return c.json({ error: 'file not found' }, 404);
    const headers = new Headers();
    object.writeHttpMetadata(headers);
    headers.set('etag', object.httpEtag);
    headers.set('cache-control', 'public, max-age=31536000, immutable');
    return new Response(object.body, { headers });
  });

  // ----- simple resources -----
  crud(app, '/api/skills', 'skills', {
    required: ['name'],
    map: (b) => ({
      name: str(b.name),
      proficiency: str(b.proficiency, 'intermediate'),
      category: str(b.category),
      display_order: Number(b.displayOrder ?? b.display_order ?? 0) || 0,
      icon_url: b.iconUrl ?? b.icon_url ?? null,
    }),
  });

  crud(app, '/api/experience', 'experience', {
    required: ['company', 'role'],
    map: (b) => ({
      company: str(b.company),
      role: str(b.role),
      location: str(b.location),
      start_date: str(b.startDate ?? b.start_date),
      end_date: b.endDate ?? b.end_date ?? null,
      current: intFlag(b.current),
      description: str(b.description),
      technologies_json: json(b.technologies),
      display_order: Number(b.displayOrder ?? b.display_order ?? 0) || 0,
    }),
  });

  crud(app, '/api/education', 'education', {
    required: ['institution'],
    map: (b) => ({
      institution: str(b.institution),
      qualification: str(b.qualification),
      course: str(b.course),
      start_year: str(b.startYear ?? b.start_year),
      end_year: b.endYear ?? b.end_year ?? null,
      description: str(b.description),
      display_order: Number(b.displayOrder ?? b.display_order ?? 0) || 0,
    }),
  });

  crud(app, '/api/socials', 'social_links', {
    required: ['platform', 'url'],
    map: (b) => ({
      platform: str(b.platform),
      url: str(b.url),
      display_order: Number(b.displayOrder ?? b.display_order ?? 0) || 0,
      enabled: b.enabled == null ? 1 : intFlag(b.enabled),
    }),
  });

  // ----- profile (single row, merge update — absent keys keep old values) -----
  app.put(
    '/api/profile',
    requireAdmin,
    wrap(async (c) => {
      const b = await body(c);
      const existing =
        ((await c.env.DB.prepare('SELECT * FROM portfolio_profile WHERE id = 1').first()) as Record<
          string,
          unknown
        > | null) ?? {};
      const pick = (camel: string, snake: string, fallback = '') => {
        if (b[camel] !== undefined) return str(b[camel]);
        if (b[snake] !== undefined) return str(b[snake]);
        const old = existing[snake];
        return old == null ? fallback : String(old);
      };
      const pickJson = (camel: string, snake: string) => {
        if (b[camel] !== undefined) return json(b[camel]);
        if (b[snake] !== undefined) return json(b[snake]);
        const old = existing[snake];
        return typeof old === 'string' ? old : '[]';
      };
      const pickUrl = (camel: string, snake: string) => {
        if (b[camel] !== undefined) return b[camel] == null || b[camel] === '' ? null : String(b[camel]);
        if (b[snake] !== undefined) return b[snake] == null || b[snake] === '' ? null : String(b[snake]);
        const old = existing[snake];
        return old == null ? null : String(old);
      };
      const row = {
        name: existing['name'] == null && b.name === undefined ? 'John Doe' : pick('name', 'name', 'John Doe'),
        headline: pick('headline', 'headline'),
        title: pick('title', 'title'),
        intro: pick('intro', 'intro'),
        bio: pick('bio', 'bio'),
        email: pick('email', 'email'),
        phone: pick('phone', 'phone'),
        location: pick('location', 'location'),
        availability: pick('availability', 'availability'),
        years_experience: pick('yearsExperience', 'years_experience'),
        current_role: pick('currentRole', 'current_role'),
        interests_json: pickJson('interests', 'interests_json'),
        resume_url: pickUrl('resumeUrl', 'resume_url'),
        profile_image_url: pickUrl('profileImageUrl', 'profile_image_url'),
        updated_at: now(),
      };
      const cols = Object.keys(row);
      await c.env.DB.prepare(
        `INSERT INTO portfolio_profile (id, ${cols.join(', ')}) VALUES (1, ${cols.map(() => '?').join(', ')})
         ON CONFLICT(id) DO UPDATE SET ${cols.map((k) => `${k} = excluded.${k}`).join(', ')}`,
      )
        .bind(...Object.values(row))
        .run();
      return c.json(await c.env.DB.prepare('SELECT * FROM portfolio_profile WHERE id = 1').first());
    }),
  );

  // ----- file uploads → R2 (§22) -----
  app.post(
    '/api/uploads',
    requireAdmin,
    wrap(async (c) => {
      const form = await c.req.parseBody();
      const file = form['file'];
      if (!(file instanceof File)) throw new HttpError(400, 'attach a file as "file"');
      // Images + PDF resumes (§22–§23). Client compresses images before upload.
      const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/pdf'];
      if (!allowed.includes(file.type)) {
        throw new HttpError(400, `unsupported type ${file.type || 'unknown'} (jpeg/png/webp/gif/pdf only)`);
      }
      const maxBytes = 8 * 1024 * 1024;
      if (file.size > maxBytes) throw new HttpError(400, 'file too large (8 MB max)');
      const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_') || 'upload';
      const key = `uploads/${new Date().toISOString().slice(0, 10)}-${uid().slice(0, 8)}-${safeName}`;
      await c.env.FILES.put(key, await file.arrayBuffer(), {
        httpMetadata: { contentType: file.type },
      });
      const base = (c.env.R2_PUBLIC_URL ?? '').replace(/\/$/, '');
      // If no public URL configured, return proxy path via the worker itself.
      const publicUrl = base ? `${base}/${key}` : null;
      return c.json({ key, url: publicUrl, proxyUrl: `/api/files/${key}` }, 201);
    }),
  );
}
