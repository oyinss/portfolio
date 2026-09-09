-- Seed rows mirroring the Flutter mock data (swapped out in Phase 4).

INSERT INTO portfolio_profile
  (id, name, headline, title, intro, bio, email, phone, location, availability,
   years_experience, current_role, interests_json)
VALUES
  (1, 'John Doe', 'HELLO, I''M', 'Flutter & Backend Developer',
   'I build modern web and mobile applications.',
   'I''m a Flutter developer focused on building high-performance applications for mobile and web.',
   'hello@example.com', '+234 800 000 0000', 'Lagos, Nigeria', 'Open to opportunities',
   '3+ Years', 'Senior Flutter Developer',
   '["Mobile Apps","Backend Systems","UI Design","Open Source"]');

INSERT INTO projects
  (id, title, slug, short_description, description, live_url, github_url,
   technologies_json, type, featured, status, display_order, date_label,
   problem, solution, features_json)
VALUES
  ('p1', 'Loan Management System', 'loan-management-system',
   'Platform for managing loan applications, repayments and customer accounts.',
   'A full platform for managing loan applications, repayments and customer accounts.',
   'https://example.com/loan-app', 'https://github.com/example/loan-app',
   '["Flutter","Laravel","PostgreSQL"]', 'Web App', 1, 'published', 1, '2025',
   'Loan officers tracked applications across spreadsheets.',
   'A single system with intake, approvals and reporting.',
   '["Application intake & approvals","Repayment tracking","Customer accounts","Admin reports"]'),
  ('p2', 'E-commerce Platform', 'ecommerce-platform',
   'Storefront with cart, checkout and order management.',
   'A complete e-commerce storefront with cart, checkout and admin panel.',
   'https://example.com/shop', 'https://github.com/example/shop',
   '["Flutter","Firebase","Stripe"]', 'Mobile + Web', 1, 'published', 2, '2024',
   'Small retailers needed an affordable storefront.',
   'One Flutter codebase for mobile and web.',
   '["Product catalog & search","Cart & checkout","Order tracking","Admin panel"]'),
  ('p3', 'Portfolio Website', 'portfolio-website',
   'This reusable portfolio platform itself.',
   'The self-hosted, configurable developer portfolio CMS.',
   NULL, 'https://github.com/example/portfolio',
   '["Flutter","Cloudflare Workers","D1"]', 'Open Source', 1, 'published', 3, '2026',
   'Developers rebuild portfolios from scratch.',
   'A clone-deploy-configure system.',
   '["Admin dashboard","Theme system","Project management","R2 file uploads"]'),
  ('p4', 'Task Tracker API', 'task-tracker-api',
   'REST API for teams with boards and assignments.',
   'A REST API for team task tracking.',
   NULL, 'https://github.com/example/tasks',
   '["Laravel","PostgreSQL","Docker"]', 'Backend', 0, 'published', 4, '2024',
   'Teams needed a simple self-hosted tool.',
   'A clean REST API with token auth.',
   '["Boards & tasks","Assignments","Activity log","API tokens"]'),
  ('p5', 'Weather App Concept', 'weather-app-concept',
   'Experimental weather UI — currently a draft.',
   'Design experiment, not published yet.',
   NULL, NULL, '["Flutter"]', 'Concept', 0, 'draft', 5, '2026', '', '', '[]');

INSERT INTO skills (id, name, proficiency, category, display_order) VALUES
  ('s1', 'Flutter', 'advanced', 'Mobile', 1),
  ('s2', 'Dart', 'advanced', 'Languages', 2),
  ('s3', 'Laravel', 'advanced', 'Backend', 3),
  ('s4', 'PHP', 'advanced', 'Languages', 4),
  ('s5', 'JavaScript', 'intermediate', 'Languages', 5),
  ('s6', 'PostgreSQL', 'intermediate', 'Backend', 6),
  ('s7', 'Firebase', 'intermediate', 'Backend', 7),
  ('s8', 'Cloudflare', 'intermediate', 'DevOps', 8),
  ('s9', 'Git', 'advanced', 'Tools', 9),
  ('s10', 'Docker', 'intermediate', 'DevOps', 10),
  ('s11', 'Figma', 'beginner', 'Design', 11);

INSERT INTO experience
  (id, company, role, location, start_date, end_date, current, description, technologies_json, display_order)
VALUES
  ('e1', 'NovaTech Solutions', 'Senior Flutter Developer', 'Lagos, Nigeria',
   '2024', NULL, 1, 'Built and maintained cross-platform applications.',
   '["Flutter","Firebase","Cloudflare"]', 1),
  ('e2', 'BrightStack', 'Backend Developer', 'Remote',
   '2022', '2024', 0, 'Designed REST APIs and database schemas.',
   '["Laravel","PostgreSQL","Docker"]', 2),
  ('e3', 'Freelance', 'Mobile Developer', 'Remote',
   '2021', '2022', 0, 'Shipped apps for small businesses.',
   '["Flutter","Firebase"]', 3);

INSERT INTO education
  (id, institution, qualification, course, start_year, end_year, description, display_order)
VALUES
  ('ed1', 'University of Lagos', 'B.Sc', 'Computer Science',
   '2020', '2024', 'Focused on software engineering and databases.', 1);

INSERT INTO social_links (id, platform, url, display_order, enabled) VALUES
  ('soc1', 'GitHub', 'https://github.com/example', 1, 1),
  ('soc2', 'LinkedIn', 'https://linkedin.com/in/example', 2, 1),
  ('soc3', 'X', 'https://x.com/example', 3, 1);

INSERT INTO portfolio_settings (key, value) VALUES
  ('site_title', 'John Doe — Portfolio'),
  ('default_theme', 'blue'),
  ('default_brightness', 'dark'),
  ('contact_email', 'hello@example.com'),
  ('seo_description', 'Flutter & Backend Developer portfolio.');
