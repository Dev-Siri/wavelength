use std::path::PathBuf;

use anyhow::Result;
use tauri::{AppHandle, Manager};
use tokio::fs;

const DOWNLOAD_DIR: &str = "downloads";
const DOWNLOAD_META: &str = "downloads-meta.json";
const SETTINGS_FILE: &str = "settings.json";

pub async fn get_downloads_path(app: &AppHandle) -> Result<PathBuf> {
    let mut path = app.path().app_data_dir()?;
    path.push(DOWNLOAD_DIR);

    if !fs::try_exists(&path).await? {
        fs::create_dir_all(&path).await?;
    }

    Ok(path)
}

pub async fn get_downloads_meta_path(app: &AppHandle) -> Result<PathBuf> {
    let mut path = app.path().app_data_dir()?;

    if !fs::try_exists(&path).await? {
        fs::create_dir_all(&path).await?;
    }

    path.push(DOWNLOAD_META);
    if !fs::try_exists(&path).await? {
        fs::write(&path, "[]").await?;
    }

    Ok(path)
}

pub async fn get_settings_path(app: &AppHandle) -> Result<PathBuf> {
    let mut path = app.path().app_data_dir()?;

    if !fs::try_exists(&path).await? {
        fs::create_dir_all(&path).await?;
    }

    path.push(SETTINGS_FILE);
    if !fs::try_exists(&path).await? {
        fs::write(&path, "{}").await?;
    }

    Ok(path)
}
