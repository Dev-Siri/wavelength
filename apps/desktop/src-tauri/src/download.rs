use std::path::Path;
use tauri::Result;
use tokio::fs;

use crate::stream_downloader::StreamDownloader;

#[tauri::command]
pub async fn download_track(stream_url: &str, output: &str) -> Result<()> {
    if let Some(parent) = Path::new(output).parent() {
        fs::create_dir_all(parent).await?;
    }

    let workers = num_cpus::get();
    let stream_downloader = StreamDownloader::new(workers);

    stream_downloader.download(stream_url, output).await?;
    Ok(())
}
