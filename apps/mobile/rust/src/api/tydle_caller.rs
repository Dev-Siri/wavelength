use anyhow::{bail, Result};
use flutter_rust_bridge::frb;
use tydle::{Ext, Extract, Filterable, Tydle, TydleOptions, VideoId, YtStreamSource};

#[derive(Clone)]
pub struct StreamMetadata {
    pub bitrate: f64,
    pub ext: String,
    pub codec: String,
    pub video_id: String,
    pub source: String,
}

#[derive(Clone)]
pub struct Stream {
    pub metadata: StreamMetadata,
    pub url: String,
}

#[frb]
pub async fn fetch_highest_audio_stream(video_id: String) -> Result<Stream> {
    let tydle = Tydle::new(TydleOptions::default())?;
    let id = VideoId::new(&video_id)?;
    let audio_streams = tydle
        .get_streams(&id)
        .await?
        .streams
        .audio_only()
        .only_urls()
        .with_highest_bitrate()
        .iter()
        .filter(|s| matches!(s.ext, Ext::Mp4 | Ext::M4a))
        .cloned()
        .collect::<Vec<_>>();

    let Some(stream) = audio_streams.first().cloned() else {
        bail!("Failed to get any audio streams.");
    };

    let YtStreamSource::URL(source) = &stream.source else {
        bail!("Audio streams available require signature deciphering.")
    };

    let stream_metadta = StreamMetadata {
        bitrate: stream.tbr,
        codec: stream.codec.acodec.unwrap_or("none".to_owned()),
        ext: stream.ext.as_str().to_owned(),
        source: "YouTube (tydle)".to_owned(),
        video_id: video_id,
    };

    let stream = Stream {
        metadata: stream_metadta,
        url: source.to_owned(),
    };

    Ok(stream)
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
