CREATE TYPE event_type AS ENUM ('play_start', 'play_30s', 'skip_fast');

CREATE TABLE IF NOT EXISTS "track_events" (
  event_id CHAR(36) PRIMARY KEY,
  event_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  video_id VARCHAR(11) NOT NULL,
  email VARCHAR(255) NOT NULL,
  event_type event_type NOT NULL
);
