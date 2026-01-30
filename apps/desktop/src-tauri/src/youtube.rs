use std::env;

use anyhow::anyhow;
use base64::{prelude::BASE64_STANDARD, Engine};
use tauri::{Result, State};
use tokio::sync::Mutex;
use tydle::{
    cookies::parse_netscape_cookies, Cipher, Extract, Filterable, Tydle, TydleOptions, VideoId,
    YtStreamSource,
};

use crate::{cache::CachedStream, AppState};

pub fn init_extractor() -> anyhow::Result<Tydle> {
    let cookies_base64 = env::var("COOKIES_BASE64")?;
    let cookies_bytes = BASE64_STANDARD.decode(cookies_base64)?;
    let cookies = String::from_utf8(cookies_bytes)?;
    let tydle_instance = Tydle::new(TydleOptions {
        auth_cookies: parse_netscape_cookies(cookies)?,
        ..Default::default()
    })?;

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
        .only_signatures()
        .into_iter()
        .filter(|s| s.codec.acodec.is_some())
        .collect::<Vec<_>>();

    let Some(stream) = audio_streams.first().cloned() else {
        return Err(anyhow!("Failed to get any audio streams.").into());
    };

    let YtStreamSource::Signature(signature) = stream.source else {
        return Err(anyhow!("No suitable audio streams available.").into());
    };

    let tydle = state.tydle.clone();
    let player_url = yt_stream_response.player_url.clone();

    let source = tauri::async_runtime::spawn_blocking(move || {
        tauri::async_runtime::block_on(async {
            tydle.decipher_signature(signature, player_url).await
        })
    })
    .await??;

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
        .only_signatures()
        .into_iter()
        .filter(|s| s.codec.vcodec.is_some())
        .collect::<Vec<_>>();

    let Some(stream) = audio_streams.first().cloned() else {
        return Err(anyhow!("Failed to get any video streams.").into());
    };

    let YtStreamSource::Signature(signature) = stream.source else {
        return Err(anyhow!("No suitable video streams available.").into());
    };

    let tydle = state.tydle.clone();
    let player_url = yt_stream_response.player_url.clone();

    let source = tauri::async_runtime::spawn_blocking(move || {
        tauri::async_runtime::block_on(async {
            tydle.decipher_signature(signature, player_url).await
        })
    })
    .await??;

    state
        .stream_url_cache
        .insert(cache_key, CachedStream::new(source.clone()));

    Ok(Some(source))
}
