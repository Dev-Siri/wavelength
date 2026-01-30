use tokio::time::{Duration, Instant};

// 6 hours.
pub const STREAM_TTL: Duration = Duration::from_secs(6 * 60 * 60);

#[derive(Clone)]
pub struct CachedStream {
    pub url: String,
    pub expires_at: Instant,
}

impl CachedStream {
    pub fn new(url: String) -> Self {
        Self {
            url,
            expires_at: Instant::now() + STREAM_TTL,
        }
    }

    pub fn is_valid(&self) -> bool {
        Instant::now() < self.expires_at
    }
}
