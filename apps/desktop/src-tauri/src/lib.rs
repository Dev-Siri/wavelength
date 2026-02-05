use dashmap::DashMap;
use std::{env, sync::Arc};

use tauri::{tray::TrayIconBuilder, Manager};

mod audio_server;
mod cache;
mod download;
mod stream_downloader;
mod youtube;

use tokio::sync::Mutex;
use tydle::Tydle;

use crate::cache::CachedStream;

pub struct AppState {
    pub tydle: Arc<Tydle>,
    pub stream_url_cache: DashMap<String, CachedStream>,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    audio_server::start_stream_server();
    tauri::Builder::default()
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let tydle = youtube::init_extractor()?;

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
            youtube::fetch_highest_bitrate_video_stream_url,
            download::download_track
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
