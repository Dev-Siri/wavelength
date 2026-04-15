import { z } from "zod";

export const streamMetadataSchema = z.object({
  bitrate: z.number(),
  ext: z.string(),
  codec: z.string(),
});

export const streamSchema = z.object({
  metadata: streamMetadataSchema,
  url: z.string(),
});

export const playabilityStatusSchema = z.enum(["PLAYABLE", "UNPLAYABLE", "UNAVAILABLE"]);
export const playabilityStatusResponseSchema = z.object({
  playabilityStatus: playabilityStatusSchema,
});

export const hlsStreamMetadataSchema = z.object({
  streamId: z.string(),
  bitrate: z.number(),
  codec: z.string(),
  container: z.string(),
  durationSeconds: z.number(),
  sampleRate: z.number(),
});

export const hlsStreamSourceSchema = z.object({
  metadata: hlsStreamMetadataSchema,
  source: z.string(),
});

export type StreamMetadata = z.infer<typeof streamMetadataSchema>;
export type Stream = z.infer<typeof streamSchema>;
export type PlayabilityStatus = z.infer<typeof playabilityStatusSchema>;
export type HlsStreamSource = z.infer<typeof hlsStreamSourceSchema>;
export type HlsStreamMetadata = z.infer<typeof hlsStreamMetadataSchema>;
