CREATE TABLE IF NOT EXISTS "playlists" (
  playlist_id CHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  cover_image TEXT,
  author_google_email VARCHAR(255) NOT NULL,
  author_name VARCHAR(255) NOT NULL,
  author_image TEXT NOT NULL,
  is_public BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
