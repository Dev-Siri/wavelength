use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct MusicTrack {
    pub title: String,
    #[serde(rename = "videoId")]
    pub video_id: String,
    pub thumbnail: String,
    pub duration: String,
    #[serde(rename = "isExplicit")]
    pub is_explicit: bool,
    pub artists: Vec<MusicTrackArtist>,
    pub album: Option<MusicTrackAlbum>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct MusicTrackArtist {
    pub title: String,
    #[serde(rename = "browseId")]
    pub browse_id: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct MusicTrackAlbum {
    pub title: String,
    #[serde(rename = "browseId")]
    pub browse_id: String,
}
