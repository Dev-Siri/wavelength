CREATE TABLE IF NOT EXISTS "stream_metadata" (
  stream_id CHAR(36) PRIMARY KEY,
  video_id VARCHAR(11) NOT NULL,
  bitrate FLOAT NOT NULL,
  codec VARCHAR(30) NOT NULL,
  container VARCHAR(10) NOT NULL,
  duration_seconds FLOAT NOT NULL,
  -- Hi-fi refers to the existence of 256kbps (AAC) or 320kpbs (AAC) streams.
  is_hifi_available BOOLEAN DEFAULT FALSE,
  is_lossless_available VARCHAR(6) NULL,
  sample_rate INTEGER DEFAULT 44100,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
