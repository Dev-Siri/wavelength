CREATE TABLE IF NOT EXISTS "labels" (
  label_id CHAR(36) PRIMARY KEY,
  isrc CHAR(12) NOT NULL,
  title VARCHAR(255) NOT NULL,
  artist VARCHAR(255) NOT NULL,
  is_explicit BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  dolby_audio_id VARCHAR(30) NULL,
  tidal_id VARCHAR(30) NOT NULL,
  youtube_music_id VARCHAR(11) NOT NULL
);
