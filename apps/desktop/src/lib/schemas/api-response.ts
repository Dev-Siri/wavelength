import { z } from "zod";

export const successResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.literal(true),
    data: dataSchema,
  });

export const errorResponseSchema = z.object({
  success: z.literal(false),
  message: z.string(),
});

export const apiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.discriminatedUnion("success", [successResponseSchema(dataSchema), errorResponseSchema]);

export type ApiResponse<T extends z.ZodTypeAny> =
  | { success: true; data: z.infer<T> }
  | z.infer<typeof errorResponseSchema>;
