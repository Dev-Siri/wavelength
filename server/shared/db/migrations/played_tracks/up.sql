CREATE TYPE video_type AS ENUM ('track', 'uvideo');

CREATE TABLE IF NOT EXISTS "played_tracks" (
  video_id VARCHAR(11) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  artist VARCHAR(255) NOT NULL,
  album VARCHAR(255) NOT NULL,
  duration INTEGER NOT NULL,
  video_type video_type NOT NULL
);
