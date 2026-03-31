import type { SettingKey } from "$lib/schemas/settings";

export interface SettingDescriptionOption {
  title: string;
  description: string;
  settingKey: SettingKey;
}

export const defaultSettings = {
  disableMusicVideoPreview: true,
  showStats: true,
  playbackQuality: "standard",
} as const;

export const displaySettings = [
  {
    title: "Disable music video preview.",
    description: "Entirely disable showing music video previews in the lyrics panel.",
    settingKey: "disableMusicVideoPreview",
  },
] satisfies SettingDescriptionOption[];

export const playbackSettings = [
  {
    title: "Preferred playback quality.",
    description: "Use selected quality when available. Higher qualities may require more data.",
    settingKey: "playbackQuality",
  },
] satisfies SettingDescriptionOption[];

export const advancedSettings = [
  {
    title: "Stats for nerds.",
    description: "View a music stream's metadata like bitrate, extension, and codecs.",
    settingKey: "showStats",
  },
] satisfies SettingDescriptionOption[];

export const playbackQualities = [
  {
    key: "standard",
    uiText: "Standard (~128kbps)",
  },
  {
    key: "hifiBase",
    uiText: "High (256kbps)",
  },
  {
    key: "hifiTop",
    uiText: "Hi-Fi (320kbps)",
  },
  {
    key: "lossless",
    uiText: "Lossless (16-bit/44.1kHz, max 24-bit)",
  },
] as const;

export const playbackQualityMap = {
  standard: "Standard (~128kbps)",
  hifiBase: "High (256kbps)",
  hifiTop: "Hi-Fi (320kbps)",
  lossless: "Lossless (16-bit/44.1kHz, max 24-bit)",
} as const;

export const playbackQualityBitrateMap = {
  standard: 128,
  hifiBase: 256,
  hifiTop: 320,
  lossless: "lossless",
} as const;
