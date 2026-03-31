import { dev } from "$app/environment";

export const PROD_URL = "https://mavelength.vercel.app";
export const BASE_URL = dev ? "http://localhost:5173" : PROD_URL;
export const STREAM_PLAYBACK_URL = "http://localhost:17842";
