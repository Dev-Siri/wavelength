CREATE TABLE IF NOT EXISTS "follows" (
  follow_id CHAR(36) PRIMARY KEY,
  follower_email VARCHAR(255) NOT NULL,
  followed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  artist_name VARCHAR(255) NOT NULL,
  artist_thumbnail VARCHAR(350) NOT NULL,
  artist_browse_id VARCHAR(255) NOT NULL
);
