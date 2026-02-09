use std::path::Path;
use tauri::Result;
use tokio::fs;

use crate::stream_downloader::StreamDownloader;

#[tauri::command]
pub async fn download_track(
    stream_url: &str,
    music_video_stream_url: &str,
    output: &str,
) -> Result<()> {
    if let Some(parent) = Path::new(output).parent() {
        fs::create_dir_all(parent).await?;
    }

    let workers = num_cpus::get();
    let stream_downloader = StreamDownloader::new(workers);

    let stream_out = format!("{}.m4a", output);
    let music_video_stream_out = format!("{}.mp4", output);

    tokio::try_join!(
        stream_downloader.download(stream_url, &stream_out),
        stream_downloader.download(music_video_stream_url, &music_video_stream_out)
    )?;

    Ok(())
}
