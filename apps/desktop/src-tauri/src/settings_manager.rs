use serde::{Deserialize, Serialize};
use tauri::{AppHandle, Emitter, Result};
use tokio::fs;

use crate::paths;

const SETTINGS_UPDATE: &str = "settings-update";

#[derive(Debug, Default, Serialize, Deserialize)]
pub enum PlaybackQuality {
    #[default]
    #[serde(rename = "standard")] // ~128kbps
    Standard,
    #[serde(rename = "hifiBase")] // 256kbps
    HifiBase,
    #[serde(rename = "hifiTop")] // 320kbps
    HifiTop,
    #[serde(rename = "lossless")] // ~1,520kbps
    Lossless,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Settings {
    #[serde(default = "default_false", rename = "disableMusicVideoPreview")]
    pub disable_music_video_preview: bool,
    #[serde(default = "default_false", rename = "showStats")]
    pub show_stats: bool,
    #[serde(default = "default_playback_quality", rename = "playbackQuality")]
    pub playback_quality: PlaybackQuality,
    #[serde(default = "default_true", rename = "discordMode")]
    pub discord_mode: bool,
}

fn default_false() -> bool {
    false
}

fn default_true() -> bool {
    true
}

fn default_playback_quality() -> PlaybackQuality {
    PlaybackQuality::Standard
}

pub async fn fetch_settings(app: &AppHandle) -> Result<Settings> {
    let settings_path = paths::get_settings_path(app).await?;
    let settings_file_contents = fs::read(settings_path).await?;
    let settings: Settings = serde_json::from_slice(&settings_file_contents)?;

    Ok(settings)
}

#[tauri::command]
pub async fn get_settings(app: AppHandle) -> Result<Settings> {
    fetch_settings(&app).await
}

#[tauri::command]
pub async fn set_settings(app: AppHandle, updated_settings: Settings) -> Result<()> {
    let settings_path = paths::get_settings_path(&app).await?;
    let updated_settings = serde_json::to_vec(&updated_settings)?;

    fs::write(settings_path, updated_settings).await?;

    app.emit(SETTINGS_UPDATE, ())?;

    Ok(())
}
