import { z } from "zod";

export const settingsSchema = z.object({
  disableMusicVideoPreview: z.boolean(),
  showStats: z.boolean(),
  playbackQuality: z.enum(["standard", "hifiBase", "hifiTop", "lossless"]),
  discordMode: z.boolean(),
});

export type Settings = z.infer<typeof settingsSchema>;
export type SettingKey = keyof Settings;
