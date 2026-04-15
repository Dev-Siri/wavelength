import { invoke } from "@tauri-apps/api/core";
import { z } from "zod";

import { streamSchema } from "$lib/schemas/stream";

export async function fetchHighestBitrateAudioStreamUrl(videoId: string) {
  const audioStreamUrl = await invoke("fetch_highest_bitrate_audio_stream_url", { videoId });
  return streamSchema.parse(audioStreamUrl);
}

export async function fetchHighestQualityVideoStreamUrl(videoId: string) {
  const videoStreamUrl = await invoke("fetch_highest_quality_video_stream_url", { videoId });
  return z.string().parse(videoStreamUrl);
}

export async function prefetchTrack(videoId: string) {
  await invoke("prefetch_track", { videoId });
}
