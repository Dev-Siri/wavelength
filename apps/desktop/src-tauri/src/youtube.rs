use tauri::{Result, State};
use tokio::sync::Mutex;
use tydle::{Extract, Filterable, VideoId, YtStreamSource};

use crate::AppState;

#[tauri::command]
pub async fn fetch_highest_bitrate_audio_stream_url(
    state: State<'_, Mutex<AppState>>,
    video_id: &str,
) -> Result<Option<String>> {
    let state = state.lock().await;

    let parsed_v_id = VideoId::new(video_id)?;
    let Some(stream) = state
        .tydle
        .get_streams(&parsed_v_id)
        .await?
        .streams
        .audio_only()
        .only_urls()
        .with_highest_bitrate()
        .first()
        .cloned()
    else {
        return Ok(None);
    };

    let url = match stream.source {
        YtStreamSource::URL(url) => url,
        _ => return Ok(None),
    };

    Ok(Some(url))
}
