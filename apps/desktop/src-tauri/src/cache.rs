use tokio::time::{Duration, Instant};

use crate::youtube::Stream;

// 6 hours.
pub const STREAM_TTL: Duration = Duration::from_secs(6 * 60 * 60);

#[derive(Clone)]
pub struct CachedStream {
    pub stream: Stream,
    pub expires_at: Instant,
}

impl CachedStream {
    pub fn new(stream: Stream) -> Self {
        Self {
            stream,
            expires_at: Instant::now() + STREAM_TTL,
        }
    }

    pub fn is_valid(&self) -> bool {
        Instant::now() < self.expires_at
    }
}
