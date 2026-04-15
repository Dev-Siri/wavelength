import { z } from "zod";

export const imageSchema = z.object({
  url: z.string(),
  key: z.string(),
  name: z.string(),
});

export const themeColorSchema = z.object({
  r: z.number(),
  g: z.number(),
  b: z.number(),
});

export const coverEffectSchema = z.object({
  colors: z.array(themeColorSchema),
});

export type ThemeColor = z.infer<typeof themeColorSchema>;
