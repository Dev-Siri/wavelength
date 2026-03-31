import { invoke } from "@tauri-apps/api/core";
import { z } from "zod";

import { musicTrackSchema, type MusicTrack } from "$lib/schemas/music-track";

export async function downloadTrack(downloadDetails: { track: MusicTrack; downloadId: string }) {
  await invoke("download_track", downloadDetails);
}

export async function getDownloadedSource(videoId: string) {
  const downloadSource = await invoke("get_download_source", { videoId });
  return z.string().parse(downloadSource);
}

export async function deleteDownload(videoId: string) {
  await invoke("delete_download", { videoId });
}

export async function getDownloads() {
  const downloads = await invoke("get_downloads");
  return z.array(musicTrackSchema).parse(downloads);
}

export async function isDownloaded(videoId: string) {
  const downloadCheck = await invoke("is_downloaded", { videoId });
  return z.boolean().parse(downloadCheck);
}
