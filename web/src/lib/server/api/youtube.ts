import { PRIVATE_GOOGLE_API_KEY } from "$env/static/private";
import { google } from "googleapis";

import createYoutubeClient from "./interface/client.js";

/**
 * The Rapid API wrapper client for the YouTube Music API.
 *
 * For the YouTube V3 Official API, use `youtubeV3Api` instead.
 */
export const youtubeClient = createYoutubeClient();

/**
 * The Official YouTube V3 Client from `googleapis`.
 */
export const youtubeV3Api = google.youtube({
  version: "v3",
  auth: PRIVATE_GOOGLE_API_KEY,
});
