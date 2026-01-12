CREATE TABLE IF NOT EXISTS "likes" (
  like_id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  thumbnail TEXT NOT NULL,
  is_explicit BOOLEAN NOT NULL,
  duration VARCHAR(10) NOT NULL,
  video_id VARCHAR(11) NOT NULL,
  video_type video_type NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
