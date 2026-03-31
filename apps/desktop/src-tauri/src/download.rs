use anyhow::anyhow;
use futures_util::StreamExt;
use reqwest::Client;
use tauri::{AppHandle, Emitter, Result, State};
use tokio::{
    fs::{self, OpenOptions},
    io::AsyncWriteExt,
    sync::Mutex,
};

use crate::{paths, schema::MusicTrack, youtube::fetch_highest_bitrate_audio_stream_url, AppState};

const DOWNLOAD_START: &str = "download-started";
const DOWNLOAD_PROGRESS: &str = "download-progress";
const DOWNLOAD_END: &str = "download-end";

#[tauri::command]
pub async fn download_track(
    app: AppHandle,
    state: State<'_, Mutex<AppState>>,
    track: MusicTrack,
    download_id: &str,
) -> Result<()> {
    let downloads_path = paths::get_downloads_path(&app)
        .await?
        .to_str()
        .unwrap_or_default()
        .to_owned();
    let downloads_meta_path = paths::get_downloads_meta_path(&app).await?;
    let music_stream = match fetch_highest_bitrate_audio_stream_url(state, &track.video_id).await? {
        Some(url) => url,
        None => return Err(anyhow!("No available audio streams found for music track.").into()),
    };

    let stream_len = fetch_resource_len(&music_stream.url).await?;
    let stream_out = format!("{}/{}.m4a", downloads_path, track.video_id);
    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open(stream_out)
        .await?;

    let client = Client::new();
    let response = client
        .get(&music_stream.url)
        .send()
        .await
        .map_err(anyhow::Error::from)?
        .error_for_status()
        .map_err(anyhow::Error::from)?;

    let mut stream = response.bytes_stream();

    let mut downloaded: u64 = 0;

    app.emit(DOWNLOAD_START, download_id)?;

    while let Some(chunk) = stream.next().await {
        let chunk = chunk.map_err(anyhow::Error::from)?;

        file.write_all(&chunk).await?;
        downloaded += chunk.len() as u64;

        let progress = download_progress_percent(stream_len as f64, downloaded as f64);
        app.emit(DOWNLOAD_PROGRESS, progress)?;
    }

    let download_meta = fs::read(&downloads_meta_path).await?;
    let mut meta_info: Vec<MusicTrack> = serde_json::from_slice(&download_meta)?;

    if !is_meta_info_saved(&meta_info, &track.video_id) {
        meta_info.push(track);

        let updated_meta = serde_json::to_vec(&meta_info)?;
        fs::write(&downloads_meta_path, updated_meta).await?;
    }

    app.emit(DOWNLOAD_END, download_id)?;

    Ok(())
}

#[tauri::command]
pub async fn get_downloads(app: AppHandle) -> Result<Vec<MusicTrack>> {
    let downloads_meta_path = paths::get_downloads_meta_path(&app).await?;
    let file_contents = fs::read(downloads_meta_path).await?;
    let downloads: Vec<MusicTrack> = serde_json::from_slice(&file_contents)?;

    Ok(downloads)
}

#[tauri::command]
pub async fn is_downloaded(app: AppHandle, video_id: &str) -> Result<bool> {
    let downloads_meta_path = paths::get_downloads_meta_path(&app).await?;
    let file_contents = fs::read(downloads_meta_path).await?;
    let downloads: Vec<MusicTrack> = serde_json::from_slice(&file_contents)?;

    Ok(downloads
        .into_iter()
        .find(|t| t.video_id == video_id)
        .is_some())
}

#[tauri::command]
pub async fn delete_download(app: AppHandle, video_id: &str) -> Result<()> {
    let downloads_meta_path = paths::get_downloads_meta_path(&app).await?;
    let downloaded_stream_path = {
        let mut downloads_path = paths::get_downloads_path(&app).await?;

        downloads_path.push(format!("{}.m4a", video_id));
        downloads_path
    };

    fs::remove_file(downloaded_stream_path)
        .await
        .map_err(anyhow::Error::from)?;

    let file_contents = fs::read(&downloads_meta_path).await?;
    let downloads: Vec<MusicTrack> = serde_json::from_slice(&file_contents)?;
    let updated_downloads: Vec<_> = downloads
        .iter()
        .filter(|s| s.video_id != video_id)
        .collect();
    let updated_downloads_serialized = serde_json::to_vec(&updated_downloads)?;

    fs::write(&downloads_meta_path, updated_downloads_serialized).await?;

    Ok(())
}

#[tauri::command]
pub async fn get_download_source(app: AppHandle, video_id: &str) -> Result<String> {
    let mut downloads_path = paths::get_downloads_path(&app).await?;

    downloads_path.push(format!("{}.m4a", video_id));
    Ok(downloads_path.to_str().unwrap_or_default().to_string())
}

async fn fetch_resource_len(url: &str) -> anyhow::Result<u64> {
    let client = Client::new();
    let response = client.head(url).send().await?;
    Ok(response
        .headers()
        .get(reqwest::header::CONTENT_LENGTH)
        .ok_or_else(|| anyhow!("Missing Content-Length"))?
        .to_str()?
        .parse::<u64>()?)
}

fn is_meta_info_saved(meta: &Vec<MusicTrack>, video_id: &str) -> bool {
    for info in meta {
        if info.video_id == video_id {
            return true;
        }
    }

    false
}

fn download_progress_percent(total: f64, downloaded: f64) -> f64 {
    (downloaded / total) * 100.0
}
