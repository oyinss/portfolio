-- Phase 3 schema (§§32–37). Applied via `npm run migrate:local` / `:remote`.
-- Public API reads published rows only; admin auth arrives in Phase 5.

CREATE TABLE IF NOT EXISTS portfolio_profile (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  name TEXT NOT NULL,
  headline TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  intro TEXT NOT NULL DEFAULT '',
  bio TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  location TEXT NOT NULL DEFAULT '',
  availability TEXT NOT NULL DEFAULT '',
  years_experience TEXT NOT NULL DEFAULT '',
  current_role TEXT NOT NULL DEFAULT '',
  interests_json TEXT NOT NULL DEFAULT '[]',
  resume_url TEXT,
  profile_image_url TEXT,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  short_description TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  image_url TEXT,
  live_url TEXT,
  github_url TEXT,
  technologies_json TEXT NOT NULL DEFAULT '[]',
  type TEXT NOT NULL DEFAULT '',
  featured INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  display_order INTEGER NOT NULL DEFAULT 0,
  date_label TEXT NOT NULL DEFAULT '',
  problem TEXT NOT NULL DEFAULT '',
  solution TEXT NOT NULL DEFAULT '',
  features_json TEXT NOT NULL DEFAULT '[]',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);
CREATE INDEX IF NOT EXISTS idx_projects_status_order ON projects(status, display_order);
CREATE INDEX IF NOT EXISTS idx_projects_slug ON projects(slug);

CREATE TABLE IF NOT EXISTS skills (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  proficiency TEXT NOT NULL DEFAULT 'intermediate',
  category TEXT NOT NULL DEFAULT '',
  display_order INTEGER NOT NULL DEFAULT 0,
  icon_url TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE TABLE IF NOT EXISTS experience (
  id TEXT PRIMARY KEY,
  company TEXT NOT NULL,
  role TEXT NOT NULL,
  location TEXT NOT NULL DEFAULT '',
  start_date TEXT NOT NULL DEFAULT '',
  end_date TEXT,
  current INTEGER NOT NULL DEFAULT 0,
  description TEXT NOT NULL DEFAULT '',
  technologies_json TEXT NOT NULL DEFAULT '[]',
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS education (
  id TEXT PRIMARY KEY,
  institution TEXT NOT NULL,
  qualification TEXT NOT NULL DEFAULT '',
  course TEXT NOT NULL DEFAULT '',
  start_year TEXT NOT NULL DEFAULT '',
  end_year TEXT,
  description TEXT NOT NULL DEFAULT '',
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS social_links (
  id TEXT PRIMARY KEY,
  platform TEXT NOT NULL,
  url TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  enabled INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS portfolio_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT ''
);

-- Phase 5 auth (§50). Unused until admin login lands.
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

-- Optional contact storage (§31). Endpoint stubbed until Phase 5.
CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL DEFAULT '',
  message TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
  read INTEGER NOT NULL DEFAULT 0
);
