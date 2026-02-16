import staticAdapter from "@sveltejs/adapter-static";
import vercelAdapter from "@sveltejs/adapter-vercel";
import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    adapter: process.env.TAURI_BUILD ? staticAdapter({ fallback: "index.html" }) : vercelAdapter(),
    prerender: {
      crawl: false,
    },
  },
};

export default config;
