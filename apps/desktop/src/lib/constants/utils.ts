import { dev } from "$app/environment";

export const DEFAULT_MAX_VIDEO_RESULTS_LIMIT = 30;
export const DEFAULT_MAX_ARTIST_RESULTS_LIMIT = 10;
export const JS_UUID_LENGTH = 36;

export const BASE_URL = dev ? "http://localhost:5173" : "https://mavelength.vercel.app";
export const STREAM_PLAYBACK_URL = "http://localhost:17842";
