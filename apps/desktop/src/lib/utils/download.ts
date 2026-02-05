import { isTauri } from "@tauri-apps/api/core";
import { get, set } from "idb-keyval";

import type { MusicTrack } from "./validation/music-track";

import { DOWNLOAD_DIR, DOWNLOAD_STREAM_EXT } from "$lib/constants/download";
import { downloadMetaSchema } from "./validation/downloads";

export async function getDownloadsPath() {
  const { appDataDir } = await import("@tauri-apps/api/path");
  const { mkdir, BaseDirectory } = await import("@tauri-apps/plugin-fs");

  await mkdir(DOWNLOAD_DIR, { baseDir: BaseDirectory.AppData, recursive: true });
  const appData = await appDataDir();
  return `${appData}/${DOWNLOAD_DIR}`;
}

export async function getDownloadedStreamPath(videoId: string) {
  const downloadsPath = await getDownloadsPath();
  return `${downloadsPath}/${videoId}.${DOWNLOAD_STREAM_EXT}`;
}

export async function fetchDownloads() {
  const savedDownloadsMeta = await get(DOWNLOAD_DIR);
  const downloadsMeta = JSON.parse(savedDownloadsMeta);
  const parsedDownloads = downloadMetaSchema.safeParse(downloadsMeta);

  if (parsedDownloads.success) return parsedDownloads.data;

  await set(DOWNLOAD_DIR, "[]");
  return [];
}

export async function updateDownloads(newDownload: MusicTrack) {
  const savedDownloadsMeta = await get(DOWNLOAD_DIR);
  const downloadsMeta = JSON.parse(savedDownloadsMeta);
  const parsedDownloads = downloadMetaSchema.safeParse(downloadsMeta);

  if (!parsedDownloads.success) return await set(DOWNLOAD_DIR, "[]");

  const updatedDownloads = [
    newDownload,
    ...parsedDownloads.data.filter(download => download.videoId !== newDownload.videoId),
  ];
  await set(DOWNLOAD_DIR, JSON.stringify(updatedDownloads));
}

export async function deleteDownload(videoId: string) {
  const savedDownloadsMeta = await get(DOWNLOAD_DIR);
  const downloadsMeta = JSON.parse(savedDownloadsMeta);
  const parsedDownloads = downloadMetaSchema.safeParse(downloadsMeta);

  if (!parsedDownloads.success) return await set(DOWNLOAD_DIR, "[]");

  const updatedDownloads = parsedDownloads.data.filter(download => download.videoId !== videoId);
  await set(DOWNLOAD_DIR, JSON.stringify(updatedDownloads));
}

export async function isAlreadyDownloaded(videoId: string) {
  if (!isTauri()) return;

  const { exists } = await import("@tauri-apps/plugin-fs");
  const trackPath = await getDownloadedStreamPath(videoId);

  return await exists(trackPath);
}
