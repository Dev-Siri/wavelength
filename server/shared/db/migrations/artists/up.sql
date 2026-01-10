CREATE TABLE IF NOT EXISTS "artists" (
  -- artist_id is the record's unique ID.
  artist_id CHAR(36) PRIMARY KEY,
  -- browse_id is YouTube's assigned ID.
  browse_id VARCHAR(100) NOT NULL,
  authored_track_id VARCHAR(11) NOT NULL,
  title VARCHAR(255) NOT NULL
);
