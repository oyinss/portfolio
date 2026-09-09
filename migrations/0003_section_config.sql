-- Default section visibility + order (§§27–28). Absent keys = all visible.
INSERT INTO portfolio_settings (key, value) VALUES
  ('sections', '{"home":true,"about":true,"projects":true,"skills":true,"experience":true,"education":true,"contact":true}'),
  ('section_order', '["home","about","projects","skills","experience","education","contact"]')
ON CONFLICT(key) DO NOTHING;
