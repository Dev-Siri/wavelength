CREATE TABLE IF NOT EXISTS "apple_music_urls" (
  apple_music_url_id CHAR(36) PRIMARY KEY,
  isrc CHAR(12) NOT NULL,
  apple_music_url VARCHAR(255) NOT NULL
)
