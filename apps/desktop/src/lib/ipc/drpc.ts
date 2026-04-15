import { PUBLIC_DISCORD_APP_ID } from "$env/static/public";
import { invoke } from "@tauri-apps/api/core";

export async function clearDrpc() {
  await invoke("drpc_clear");
}

export async function startDrpc() {
  await invoke("drpc_start", { appId: PUBLIC_DISCORD_APP_ID });
}

export async function updateDrpcActivity(activityDetails: {
  details: string;
  state: string;
  currentTime: number;
  totalTime: number;
  thumbnail: string;
}) {
  await invoke("drpc_set_activity", {
    ...activityDetails,
    currentTime: Math.floor(activityDetails.currentTime),
    totalTime: Math.floor(activityDetails.totalTime),
  });
}
