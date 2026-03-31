import { invoke } from "@tauri-apps/api/core";

import { streamSchema } from "$lib/schemas/stream";

export async function fetchHighestBitrateAudioStreamUrl(videoId: string) {
  const audioStreamUrl = await invoke("fetch_highest_bitrate_audio_stream_url", { videoId });
  return streamSchema.parse(audioStreamUrl);
}

export async function fetchHighestBitrateVideoStreamUrl(videoId: string) {
  const videoStreamUrl = await invoke("fetch_highest_bitrate_video_stream_url", { videoId });
  return streamSchema.parse(videoStreamUrl);
}

export async function prefetchTrack(videoId: string) {
  await invoke("prefetch_track", { videoId });
}
