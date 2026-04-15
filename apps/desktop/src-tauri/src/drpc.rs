use chrono::Utc;
use discord_rich_presence::activity::{
    Activity, ActivityType, Assets, Button, StatusDisplayType, Timestamps,
};
use discord_rich_presence::{DiscordIpc, DiscordIpcClient};
use once_cell::sync::Lazy;
use std::sync::Mutex;

const WAVELENGTH_LOGO_URL: &str = "https://mavelength.vercel.app/pwa/192x192.png";
const WAVELENGTH_URL: &str = "https://mavelength.vercel.app";

static CLIENT: Lazy<Mutex<Option<DiscordIpcClient>>> = Lazy::new(|| Mutex::new(None));

#[tauri::command]
pub fn drpc_start(app_id: String) -> Result<(), String> {
    let mut client = DiscordIpcClient::new(&app_id);

    client.connect().map_err(|e| e.to_string())?;

    let mut global = CLIENT.lock().unwrap();
    *global = Some(client);

    Ok(())
}

#[tauri::command]
pub fn drpc_set_activity(
    details: String,
    state: String,
    current_time: Option<i64>,
    total_time: Option<i64>,
    thumbnail: String,
) -> Result<(), String> {
    let mut global = CLIENT.lock().unwrap();
    let client = global.as_mut().ok_or("Client not started")?;

    let mut activity = Activity::new()
        .details(details)
        .state(state)
        .status_display_type(StatusDisplayType::State)
        .buttons(vec![Button::new("Listen on Wavelength", WAVELENGTH_URL)]);

    if let (Some(current), Some(total)) = (current_time, total_time) {
        let now = Utc::now().timestamp();
        let start = now - current;
        let end = start + total;

        activity = activity.timestamps(Timestamps::new().start(start).end(end));
    }

    let assets = Assets::new()
        .large_image(thumbnail)
        .small_image(WAVELENGTH_LOGO_URL)
        .small_text("Wavelength");

    activity = activity
        .activity_type(ActivityType::Listening)
        .assets(assets);
    client.set_activity(activity).map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
pub fn drpc_clear() -> Result<(), String> {
    let mut global = CLIENT.lock().unwrap();
    let client = global.as_mut().ok_or("Client not started")?;

    client.clear_activity().ok();

    Ok(())
}

#[tauri::command]
pub fn drpc_stop() -> Result<(), String> {
    let mut global = CLIENT.lock().unwrap();

    if let Some(client) = global.as_mut() {
        client.close().ok();
    }

    *global = None;

    Ok(())
}
