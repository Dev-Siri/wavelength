use anyhow::anyhow;
use tauri::{Result, State};
use tokio::sync::Mutex;
use tydle::{Extract, Filterable, Tydle, TydleOptions, VideoId, YtStreamSource};

use crate::{cache::CachedStream, AppState};

pub fn init_extractor() -> anyhow::Result<Tydle> {
    let tydle_instance = Tydle::new(TydleOptions::default())?;

    log::info!("Tydle instance initialized.");
    Ok(tydle_instance)
}

#[tauri::command]
pub async fn fetch_highest_bitrate_audio_stream_url(
    state: State<'_, Mutex<AppState>>,
    video_id: &str,
) -> Result<Option<String>> {
    let state = state.lock().await;

    if let Some(cached_source) = state.stream_url_cache.get(video_id) {
        if cached_source.is_valid() {
            return Ok(Some(cached_source.url.clone()));
        }
    }

    let id = VideoId::new(video_id)?;
    let yt_stream_response = state.tydle.get_streams(&id).await?;
    let audio_streams = yt_stream_response
        .streams
        .only_urls()
        .audio_only()
        .with_highest_bitrate()
        .into_iter()
        .filter(|s| s.codec.acodec.is_some())
        .collect::<Vec<_>>();

    let Some(stream) = audio_streams.first().cloned() else {
        return Err(anyhow!("Failed to get any audio streams.").into());
    };

    let YtStreamSource::URL(source) = stream.source else {
        return Err(anyhow!("No suitable audio streams available.").into());
    };

    state
        .stream_url_cache
        .insert(video_id.to_string(), CachedStream::new(source.clone()));

    Ok(Some(source))
}

#[tauri::command]
pub async fn fetch_highest_bitrate_video_stream_url(
    state: State<'_, Mutex<AppState>>,
    video_id: &str,
) -> Result<Option<String>> {
    let state = state.lock().await;
    let cache_key = format!("{}-preview", video_id);

    if let Some(cached_source) = state.stream_url_cache.get(&cache_key) {
        if cached_source.is_valid() {
            return Ok(Some(cached_source.url.clone()));
        }
    }

    let id = VideoId::new(video_id)?;
    let yt_stream_response = state.tydle.get_streams(&id).await?;
    let audio_streams = yt_stream_response
        .streams
        .only_urls()
        .video_only()
        .with_highest_bitrate()
        .into_iter()
        .filter(|s| s.codec.vcodec.is_some())
        .collect::<Vec<_>>();

    let Some(stream) = audio_streams.first().cloned() else {
        return Err(anyhow!("Failed to get any video streams.").into());
    };

    let YtStreamSource::URL(source) = stream.source else {
        return Err(anyhow!("No suitable video streams available.").into());
    };

    state
        .stream_url_cache
        .insert(cache_key, CachedStream::new(source.clone()));

    Ok(Some(source))
}
