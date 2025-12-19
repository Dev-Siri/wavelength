CREATE TYPE video_type AS ENUM (
  "track",
  "uvideo"
);

CREATE TABLE IF NOT EXISTS "playlist_tracks" (
  playlist_track_id CHAR(36) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  thumbnail TEXT NOT NULL,
  is_explicit BOOLEAN NOT NULL
  duration VARCHAR(10) NOT NULL,
  playlist_id CHAR(36) NOT NULL,
  author VARCHAR(255) NOT NULL,
  video_id VARCHAR(11) NOT NULL,
  video_type video_type NOT NULL,
  position_in_playlist INTEGER NOT NULL
);
