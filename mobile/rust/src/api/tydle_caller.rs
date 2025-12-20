use anyhow::{bail, Result};
use flutter_rust_bridge::frb;
use tydle::{Ext, Extract, Filterable, Tydle, TydleOptions, VideoId, YtStreamSource};

#[frb]
pub async fn fetch_highest_audio_stream_url(video_id: String) -> Result<String> {
    let tydle = Tydle::new(TydleOptions::default())?;
    let id = VideoId::new(video_id)?;
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

    let YtStreamSource::URL(source) = stream.source else {
        bail!("Audio streams available require signature deciphering.")
    };

    Ok(source)
}

#[frb]
pub async fn fetch_highest_video_stream_url(video_id: String) -> Result<String> {
    let tydle = Tydle::new(TydleOptions::default())?;
    let id = VideoId::new(video_id)?;
    let video_streams = tydle
        .get_streams(&id)
        .await?
        .streams
        .video_only()
        .only_urls()
        .with_highest_bitrate()
        .iter()
        .filter(|s| matches!(s.ext, Ext::Mp4 | Ext::M4a))
        .cloned()
        .collect::<Vec<_>>();

    let Some(stream) = video_streams.first().cloned() else {
        bail!("Failed to get any video streams.");
    };

    let YtStreamSource::URL(source) = stream.source else {
        bail!("Video streams available require signature deciphering.")
    };

    Ok(source)
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
