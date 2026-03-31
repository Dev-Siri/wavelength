CREATE TABLE IF NOT EXISTS "saved_albums" (
  save_id CHAR(36) PRIMARY KEY,
  saver_email VARCHAR(255) NOT NULL,
  album_id VARCHAR(100) NOT NULL,
  title VARCHAR(255) NOT NULL,
  album_cover VARCHAR(255) NOT NULL,
  album_song_count INTEGER NOT NULL,
  album_duration VARCHAR(50) NOT NULL,
  album_author VARCHAR(255) NOT NULL,
  album_type VARCHAR(6) NOT NULL
);
