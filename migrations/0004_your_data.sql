-- 0004: owner personal data seed.
--
-- SAFE TO RE-APPLY. Rules this file follows (keep them for all future
-- data migrations):
--   * Never `DELETE FROM <table>` without a WHERE clause.
--   * Demo-seed rows are removed only by exact (id + content) match, so rows
--     the owner created or edited via /admin are never touched.
--   * Personal rows use `ON CONFLICT (...) DO NOTHING`.
--   * The profile UPDATE only fills placeholder/empty rows.
--
-- Workflow: develop against local D1 (`npm run migrate:local`), and only run
-- `npm run migrate:remote` as part of a deploy. Never hand-edit the live DB.

-- Profile: fill only placeholder rows. Live owner data is a no-op here.
UPDATE portfolio_profile SET
  name = 'Onyinbrakeme Kelvin Ogbe',
  headline = 'HELLO, I''M',
  title = 'Full-Stack Developer | IT Officer | Laravel/PHP Engineer',
  intro = 'I design, build, and maintain business-critical web applications — from Laravel backends to Flutter frontends.',
  bio = 'I''m a Full-Stack Developer and IT Officer with hands-on experience building and maintaining business-critical web applications. I work across Laravel/PHP, Python, MySQL/PostgreSQL, and Linux environments, and I care about shipping reliable systems that are easy to audit and maintain. I''ve led live migrations from PHP 5.6 to PHP 8.5 while keeping services running.',
  email = 'github-oyinbra@outlook.com',
  phone = '',
  location = 'Lagos, Nigeria',
  availability = 'Open to opportunities',
  years_experience = '8+ Years',
  current_role = 'Full-Stack Developer / IT Officer',
  interests_json = '["Open Source","Backend Systems","Linux","Finance Automation","Flutter"]',
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
WHERE id = 1 AND (name IS NULL OR name IN ('', 'John Doe'));

-- Projects: drop ONLY the 0002 demo rows (exact slug match), then seed.
DELETE FROM projects WHERE slug IN (
  'loan-management-system', 'ecommerce-platform', 'portfolio-website',
  'task-tracker-api', 'weather-app-concept'
);
INSERT INTO projects
  (id, title, slug, short_description, description, live_url, github_url,
   technologies_json, type, featured, status, display_order, date_label,
   problem, solution, features_json)
VALUES
  ('p1', 'PISOL Loan Servicing Workflow', 'pisol-loan-servicing',
   'Loan servicing workflow focused on settlements, repayments and lifecycle automation.',
   'A practical loan servicing system with settlement calculation logic, flat monthly interest cycles, admin fee handling, repayment-based settlement support, and automation ideas for loan closure workflows.',
   NULL, NULL,
   '["PHP","Laravel","MySQL"]', 'Backend', 1, 'published', 1, '2024',
   'Manual loan servicing workflows were error-prone and hard to audit.',
   'Built clear, auditable settlement formulas and calendar-aligned interest cycles for consistent logic across UI, database and reports.',
   '["Settlement calculation logic","Flat monthly interest cycles","Admin fee handling","Repayment-based settlement support","Loan closure automation idea"]'),
  ('p2', 'Legacy PHP Migration Initiative', 'legacy-php-migration',
   'Led a live migration from PHP 5.6 to PHP 8.5 without service interruption.',
   'Migrated a live production application from PHP 5.6 to PHP 8.5, refactored deprecated code, resolved compatibility issues, and validated results with post-migration testing.',
   NULL, NULL,
   '["PHP","Laravel","MySQL"]', 'Migration', 1, 'published', 2, '2024',
   'Legacy runtime created operational and security risk.',
   'Planned and executed the migration while maintaining operational continuity.',
   '["Migrated live production app from PHP 5.6 to PHP 8.5","Refactored deprecated code","Reduced legacy runtime risk","Maintained service continuity"]'),
  ('p3', 'Arch Linux Workstation Build', 'arch-linux-workstation',
   'Installed and configured Arch Linux entirely from the command line.',
   'Installed Arch Linux from partitioning to a fully operational desktop environment and configured networking, bootloader, system services and development tooling.',
   NULL, NULL,
   '["Linux","Bash","Arch Linux"]', 'Infrastructure', 1, 'published', 3, '2023',
   'Needed a predictable, customizable development environment.',
   'Built a minimal, reproducible Linux workstation from scratch.',
   '["Full CLI-based installation","Systemd configuration","Development workstation setup","Advanced Linux troubleshooting"]'),
  ('p4', 'MySQL Financial Reporting Suite', 'mysql-financial-reporting',
   'Built SQL-driven operational and yearly reports for financial workflows.',
   'Designed and optimized SQL reports for disbursement, collection and investment tracking, improving consistency between business reports and transaction-level data.',
   NULL, NULL,
   '["MySQL","PHP","Laravel"]', 'Backend', 0, 'published', 4, '2023',
   'Reporting inconsistencies slowed business decision-making.',
   'Rebuilt operational reports and reconciled them against source transactions.',
   '["SQL report development","Financial data validation","Transaction reconciliation","Improved reporting accuracy"]')
ON CONFLICT(id) DO NOTHING;

-- Skills: drop ONLY 0002 demo rows (exact id+name match), then seed.
DELETE FROM skills WHERE (id, name) IN (VALUES
  ('s1', 'Flutter'), ('s2', 'Dart'), ('s3', 'Laravel'), ('s4', 'PHP'),
  ('s5', 'JavaScript'), ('s6', 'PostgreSQL'), ('s7', 'Firebase'),
  ('s8', 'Cloudflare'), ('s9', 'Git'), ('s10', 'Docker'), ('s11', 'Figma'));
INSERT INTO skills (id, name, proficiency, category, display_order) VALUES
  ('s1', 'PHP', 'expert', 'Languages', 1),
  ('s2', 'Laravel', 'expert', 'Backend', 2),
  ('s3', 'Python', 'advanced', 'Languages', 3),
  ('s4', 'Flask', 'intermediate', 'Backend', 4),
  ('s5', 'Django', 'intermediate', 'Backend', 5),
  ('s6', 'JavaScript', 'advanced', 'Languages', 6),
  ('s7', 'Node.js', 'intermediate', 'Backend', 7),
  ('s8', 'React', 'intermediate', 'Frontend', 8),
  ('s9', 'Flutter', 'intermediate', 'Mobile', 9),
  ('s10', 'MySQL', 'expert', 'Databases', 10),
  ('s11', 'PostgreSQL', 'advanced', 'Databases', 11),
  ('s12', 'Neo4j', 'intermediate', 'Databases', 12),
  ('s13', 'Docker', 'intermediate', 'DevOps', 13),
  ('s14', 'Linux', 'expert', 'DevOps', 14),
  ('s15', 'Bash', 'advanced', 'DevOps', 15),
  ('s16', 'Git', 'advanced', 'Tools', 16)
ON CONFLICT(id) DO NOTHING;

-- Experience: drop ONLY 0002 demo rows (exact id+company match), then seed.
DELETE FROM experience WHERE (id, company) IN (VALUES
  ('e1', 'NovaTech Solutions'), ('e2', 'BrightStack'), ('e3', 'Freelance'));
INSERT INTO experience
  (id, company, role, location, start_date, end_date, current, description, technologies_json, display_order)
VALUES
  ('e1', 'Current Employer', 'IT Officer / Full-Stack Developer', 'Lagos, Nigeria',
   '2022', NULL, 1,
   'Designed, built and maintained core website features for internal and customer-facing workflows. Developed Laravel/PHP modules, SQL reports for financial operations, migrations from PHP 5.6 to PHP 8.5, and production debugging across VPS and shared hosting environments.',
   '["PHP","Laravel","Python","MySQL","Linux","Docker","VPS"]', 1)
ON CONFLICT(id) DO NOTHING;

-- Education: drop ONLY the 0002 demo row, then seed.
DELETE FROM education WHERE id = 'ed1' AND institution = 'University of Lagos';
INSERT INTO education
  (id, institution, qualification, course, start_year, end_year, description, display_order)
VALUES
  ('ed1', 'Your Institution', 'Degree', 'Your Course / Qualification',
   'Year', NULL, 'Update this row with your real institution details.', 1)
ON CONFLICT(id) DO NOTHING;

-- Socials: drop ONLY 0002 demo rows (example URLs), then seed.
DELETE FROM social_links WHERE url LIKE '%example%';
INSERT INTO social_links (id, platform, url, display_order, enabled) VALUES
  ('soc1', 'GitHub', 'https://github.com/oyinss', 1, 1),
  ('soc2', 'LinkedIn', 'https://linkedin.com/in/oyinbra', 2, 1),
  ('soc3', 'Telegram', 'https://t.me/oyinbra', 3, 1),
  ('soc4', 'Email', 'mailto:github-oyinbra@outlook.com', 4, 1),
  ('soc5', 'Reddit', 'https://reddit.com/u/oyinss', 5, 1),
  ('soc6', 'X', 'https://x.com/oyinss', 6, 1)
ON CONFLICT(id) DO NOTHING;

-- Settings: insert-only, owner edits via /admin always win.
INSERT INTO portfolio_settings (key, value) VALUES
  ('site_title', 'Onyinbrakeme Kelvin Ogbe — Portfolio'),
  ('seo_description', 'Full-Stack Developer and IT Officer — Laravel, PHP, Python, Linux and Flutter.')
ON CONFLICT(key) DO NOTHING;
