import { z } from "zod";

const audioQualitySchema = z.enum(["standard", "hifiBase", "hifiTop", "lossless"]);

export const settingsSchema = z.object({
  disableMusicVideoPreview: z.boolean(),
  showStats: z.boolean(),
  playbackQuality: audioQualitySchema,
  castAudioQuality: audioQualitySchema.optional(),
  discordMode: z.boolean(),
});

export type Settings = z.infer<typeof settingsSchema>;
export type SettingKey = keyof Settings;
