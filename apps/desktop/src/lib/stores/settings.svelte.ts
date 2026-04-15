import type { Settings } from "$lib/schemas/settings";

import { defaultSettings } from "$lib/constants/settings";
import { setSettings } from "$lib/ipc/settingsManager";
import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

class SettingsStore {
  settings = $state<Settings>(defaultSettings);

  async updateSettings(updatedSettings: Partial<Settings>) {
    // if (updatedSettings.playbackQuality && updatedSettings.playbackQuality === "lossless") return;

    const settingsCopy = { ...this.settings };
    const newSettings = {
      ...this.settings,
      ...updatedSettings,
    };

    this.settings = newSettings;
    await setSettings(newSettings);

    if (
      updatedSettings.playbackQuality &&
      settingsCopy.playbackQuality !== updatedSettings.playbackQuality
    ) {
      await musicPlayer.reload(true);
    }
  }
}

const settingsStore = new SettingsStore();

export default settingsStore;
