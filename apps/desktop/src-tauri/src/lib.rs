use tauri::tray::{TrayIcon, TrayIconBuilder};

pub mod youtube;

pub use youtube::*;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }

            let tray_icon: TrayIcon = TrayIconBuilder::new().tooltip("Wavelength").build(app)?;

            tray_icon.on_menu_event(|app_handle, event| match event.id.0.as_str() {
                "quit" => {
                    app_handle.exit(0);
                }
                _ => {}
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Wavelength desktop launch failed.");
}
