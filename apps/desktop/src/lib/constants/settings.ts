import type { SettingKey } from "$lib/schemas/settings";

export interface SettingDescriptionOption {
  title: string;
  description: string;
  settingKey: SettingKey;
  webHint?: string;
}

export const defaultSettings = {
  disableMusicVideoPreview: true,
  showStats: true,
  playbackQuality: "standard",
  discordMode: true,
} as const;

export const desktopOnlySettings: SettingKey[] = ["discordMode", "playbackQuality"];

export const displaySettings = [
  {
    title: "Disable music video preview.",
    description: "Entirely disable showing music video previews in the lyrics panel.",
    settingKey: "disableMusicVideoPreview",
  },
  {
    title: "Discord Mode.",
    description: "Broadcast your listening activity to Discord.",
    settingKey: "discordMode",
    webHint: "Install the Desktop app to share your WavLen listening activity on Discord.",
  },
] satisfies SettingDescriptionOption[];

export const playbackSettings = [
  {
    title: "Audio quality.",
    description: "Higher qualities require more data.",
    settingKey: "playbackQuality",
    webHint: "The Desktop app allows more quality options including Lossless.",
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
    uiText: "High Quality (256kbps)",
  },
  {
    key: "hifiTop",
    uiText: "Hi-Fi (320kbps)",
  },
  {
    key: "lossless",
    uiText: "Lossless (up to 24-bit/192kHz)",
  },
] as const;

export const playbackQualityMap = {
  standard: "Standard (~128kbps)",
  hifiBase: "High Quality (256kbps)",
  hifiTop: "Hi-Fi (320kbps)",
  lossless: "Lossless (up to 24-bit/192kHz)",
} as const;

export const playbackQualityBitrateMap = {
  standard: 128,
  hifiBase: 256,
  hifiTop: 320,
  lossless: "lossless",
} as const;

export type PlaybackQualityBitrateMap = typeof playbackQualityBitrateMap;
export type PlaybackQualityBitrate = PlaybackQualityBitrateMap[keyof PlaybackQualityBitrateMap];
