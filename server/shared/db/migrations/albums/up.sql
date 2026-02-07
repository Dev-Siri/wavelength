CREATE TABLE IF NOT EXISTS "albums" (
  -- album_id is the record's unique ID.
  album_id CHAR(36) PRIMARY KEY,
  -- browse_id is YouTube's assigned ID.
  browse_id VARCHAR(100) NOT NULL,
  track_id VARCHAR(11) NOT NULL,
  title VARCHAR(255) NOT NULL
);
