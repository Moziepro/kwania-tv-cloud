CREATE TABLE IF NOT EXISTS videos (
  id TEXT PRIMARY KEY,
  object_key TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Entertainment',
  duration REAL NOT NULL,
  mime_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
INSERT OR IGNORE INTO settings(key, value) VALUES ('anchor_ms', '0');
