use tauri::{
    tray::{TrayIcon, TrayIconBuilder},
    Manager,
};

pub mod youtube;

use tydle::{Tydle, TydleOptions};

pub struct AppState {
    pub tydle: Tydle,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            let tydle_instance = Tydle::new(TydleOptions::default())?;
            log::info!("Tydle instance initialized.");

            app.manage(AppState {
                tydle: tydle_instance,
            });

            let tray_icon: TrayIcon = TrayIconBuilder::new().tooltip("Wavelength").build(app)?;

            tray_icon.on_menu_event(|app_handle, event| match event.id.0.as_str() {
                "quit" => {
                    app_handle.exit(0);
                }
                _ => {}
            });

            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            youtube::fetch_highest_bitrate_audio_stream_url
        ])
        .run(tauri::generate_context!())
        .expect("Wavelength desktop launch failed.");
}
