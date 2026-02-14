import { z } from "zod";

export const authUserSchema = z.object({
  userId: z.string(),
  displayName: z.string(),
  email: z.string(),
  pictureUrl: z.string(),
});

export type AuthUser = z.infer<typeof authUserSchema>;
