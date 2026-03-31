import { invoke, isTauri } from "@tauri-apps/api/core";
import { get, set } from "idb-keyval";

import { defaultSettings } from "$lib/constants/settings";
import { settingsSchema, type Settings } from "$lib/schemas/settings";

const IDB_SETTINGS_KEY = "app-settings";

export async function getSettings() {
  if (!isTauri()) {
    let savedSettings = await get(IDB_SETTINGS_KEY);
    if (!savedSettings) {
      savedSettings = defaultSettings;
      await set(IDB_SETTINGS_KEY, savedSettings);
    }

    return settingsSchema.parse(savedSettings);
  }

  const settings = await invoke("get_settings");
  return settingsSchema.parse(settings);
}

export async function setSettings(updatedSettings: Settings) {
  if (!isTauri()) {
    return await set(IDB_SETTINGS_KEY, updatedSettings);
  }

  await invoke("set_settings", { updatedSettings });
}
