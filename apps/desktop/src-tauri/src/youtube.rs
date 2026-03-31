use std::{path::PathBuf, sync::Arc};

use anyhow::{anyhow, bail};
use serde::{Deserialize, Serialize};
use tauri::{Result, State};
use tokio::sync::Mutex;
use tydle::{
    Codec, DiskCacheStore, Extract, Filterable, Tydle, TydleOptions, VideoId, YtStreamSource,
};

use crate::{cache::CachedStream, AppState};

type TydleInstance = Tydle<DiskCacheStore, DiskCacheStore>;

#[derive(Clone, Serialize, Deserialize)]
pub struct StreamMetadata {
    pub bitrate: f64,
    pub ext: String,
    pub codec: Codec,
    pub video_id: String,
    pub source: String,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Stream {
    pub metadata: StreamMetadata,
    pub url: String,
}

pub fn init_extractor(cache_path: PathBuf) -> anyhow::Result<TydleInstance> {
    let tydle_instance = Tydle::new_with_cache(
        TydleOptions::default(),
        DiskCacheStore::new(cache_path.clone()),
        DiskCacheStore::new(cache_path),
    )?;

    log::info!("Tydle instance initialized.");
    Ok(tydle_instance)
}

async fn fetch_highest_bitrate_audio_stream(
    tydle: Arc<TydleInstance>,
    video_id: &str,
) -> anyhow::Result<Stream> {
    let id = VideoId::new(video_id)?;
    let yt_stream_response = tydle.get_streams(&id).await?;
    let audio_streams = yt_stream_response
        .streams
        .only_urls()
        .audio_only()
        .with_highest_bitrate()
        .into_iter()
        .filter(|s| s.codec.acodec.is_some())
        .collect::<Vec<_>>();

    log::info!(
        "YouTube returned {} audio streams for {}.",
        audio_streams.len(),
        video_id
    );
    let Some(yt_stream) = audio_streams.first().cloned() else {
        bail!("Failed to get any audio streams.");
    };

    log::info!(
        "Picked source. Playing {} {} kb/s stream.",
        yt_stream.ext.as_str(),
        yt_stream.tbr
    );

    let stream_metadata = StreamMetadata {
        bitrate: yt_stream.tbr,
        ext: yt_stream.ext.as_str().to_owned(),
        codec: yt_stream.codec,
        video_id: video_id.to_owned(),
        source: "YouTube (tydle)".to_owned(),
    };

    let YtStreamSource::URL(source) = yt_stream.source else {
        bail!("No suitable audio streams available.");
    };

    let stream = Stream {
        url: source,
        metadata: stream_metadata,
    };

    Ok(stream)
}

#[tauri::command]
pub async fn fetch_highest_bitrate_audio_stream_url(
    state: State<'_, Mutex<AppState>>,
    video_id: &str,
) -> Result<Option<Stream>> {
    let state = state.lock().await;

    if let Some(cached_source) = state.stream_url_cache.get(video_id) {
        if cached_source.is_valid() {
            return Ok(Some(cached_source.stream.clone()));
        }
    }

    let stream = fetch_highest_bitrate_audio_stream(state.tydle.clone(), video_id).await?;
    state
        .stream_url_cache
        .insert(video_id.to_string(), CachedStream::new(stream.clone()));

    Ok(Some(stream))
}

#[tauri::command]
pub async fn fetch_highest_bitrate_video_stream_url(
    state: State<'_, Mutex<AppState>>,
    video_id: &str,
) -> Result<Option<Stream>> {
    let state = state.lock().await;
    let cache_key = format!("{}-preview", video_id);

    if let Some(cached_source) = state.stream_url_cache.get(&cache_key) {
        if cached_source.is_valid() {
            return Ok(Some(cached_source.stream.clone()));
        }
    }

    let id = VideoId::new(video_id)?;
    let yt_stream_response = state.tydle.get_streams(&id).await?;
    let mut video_streams = yt_stream_response
        .streams
        .only_urls()
        .video_only()
        .into_iter()
        .collect::<Vec<_>>();

    video_streams.sort_by(|a, b| {
        b.height
            .unwrap_or(0)
            .cmp(&a.height.unwrap_or(0))
            .then_with(|| {
                b.tbr
                    .partial_cmp(&a.tbr)
                    .unwrap_or(std::cmp::Ordering::Equal)
            })
            .then_with(|| b.fps.cmp(&a.fps))
    });

    let Some(yt_stream) = video_streams.first().cloned() else {
        return Err(anyhow!("Failed to get any video streams.").into());
    };

    let stream_metadata = StreamMetadata {
        bitrate: yt_stream.tbr,
        ext: yt_stream.ext.as_str().to_owned(),
        codec: yt_stream.codec,
        video_id: video_id.to_owned(),
        source: "YouTube (tydle)".to_owned(),
    };

    let YtStreamSource::URL(source) = yt_stream.source else {
        return Err(anyhow!("No suitable video streams available.").into());
    };

    let stream = Stream {
        url: source,
        metadata: stream_metadata,
    };

    state
        .stream_url_cache
        .insert(cache_key, CachedStream::new(stream.clone()));

    Ok(Some(stream))
}

#[tauri::command]
pub async fn prefetch_track(state: State<'_, Mutex<AppState>>, video_id: &str) -> Result<()> {
    let state = state.lock().await;

    if let Some(cached_source) = state.stream_url_cache.get(video_id) {
        if cached_source.is_valid() {
            return Ok(());
        }
    }

    log::info!("Prefetching stream for {}.", video_id);
    let stream = fetch_highest_bitrate_audio_stream(state.tydle.clone(), video_id).await?;

    state
        .stream_url_cache
        .insert(video_id.to_string(), CachedStream::new(stream));

    Ok(())
}
