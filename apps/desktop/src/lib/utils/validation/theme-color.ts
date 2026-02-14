import { z } from "zod";

export const themeColorSchema = z.object({
  r: z.number(),
  g: z.number(),
  b: z.number(),
});

export type ThemeColor = z.infer<typeof themeColorSchema>;
