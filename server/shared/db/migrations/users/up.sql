CREATE TYPE auth_provider AS ENUM (
  'google',
  'mail'
);

CREATE TABLE IF NOT EXISTS "users" (
  user_id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  email_verified BOOLEAN DEFAULT FALSE,
  auth_provider auth_provider NOT NULL,
  display_name VARCHAR(255) NOT NULL,
  -- password_hash isn't always defined, outside of email/password auth it's always NULL.
  password_hash VARCHAR(255) NULL,
  picture_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
