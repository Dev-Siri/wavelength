use dashmap::DashMap;
use std::{env, sync::Arc};
#[cfg(any(target_os = "linux", windows))]
use tauri_plugin_deep_link::DeepLinkExt;

use tauri::{tray::TrayIconBuilder, Manager};

mod audio_server;
mod cache;
mod download;
mod drpc;
mod paths;
mod schema;
mod settings_manager;
mod youtube;

use tokio::sync::Mutex;
use tydle::{DiskCacheStore, Tydle};

use crate::cache::CachedStream;

pub struct AppState {
    pub tydle: Arc<Tydle<DiskCacheStore, DiskCacheStore>>,
    pub stream_url_cache: DashMap<String, CachedStream>,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    audio_server::start_stream_server();
    tauri::Builder::default()
        .plugin(tauri_plugin_deep_link::init())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_cors_fetch::init())
        .setup(|app| {
            #[cfg(any(target_os = "linux", windows))]
            {
                app.deep_link().register_all()?;
            }

            let tydle = youtube::init_extractor(app.path().cache_dir()?)?;

            app.manage(Mutex::new(AppState {
                tydle: Arc::new(tydle),
                stream_url_cache: DashMap::new(),
            }));

            TrayIconBuilder::new()
                .tooltip("WavLen")
                .icon(app.default_window_icon().unwrap().clone())
                .build(app)?;

            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }

            Ok(())
        })
        .on_window_event(|window, event| match event {
            tauri::WindowEvent::CloseRequested { api, .. } => {
                if cfg!(target_os = "macos") {
                    window.hide().unwrap();
                    api.prevent_close();
                }
            }
            _ => {}
        })
        .invoke_handler(tauri::generate_handler![
            youtube::fetch_highest_bitrate_audio_stream_url,
            youtube::fetch_highest_quality_video_stream_url,
            youtube::prefetch_track,
            download::download_track,
            download::get_downloads,
            download::delete_download,
            download::is_downloaded,
            download::get_download_source,
            settings_manager::set_settings,
            settings_manager::get_settings,
            drpc::drpc_start,
            drpc::drpc_set_activity,
            drpc::drpc_clear,
            drpc::drpc_stop,
        ])
        .build(tauri::generate_context!())
        .expect("Wavelength desktop launch failed.")
        .run(|app_handle, event| match event {
            #[cfg(target_os = "macos")]
            tauri::RunEvent::Reopen {
                has_visible_windows,
                ..
            } => {
                if !has_visible_windows {
                    let window = app_handle.get_webview_window("main").unwrap();
                    window.show().unwrap();
                    window.set_focus().unwrap();
                }
            }
            _ => {}
        });
}
