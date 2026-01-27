import { enhancedImages } from "@sveltejs/enhanced-img";
import { sveltekit } from "@sveltejs/kit/vite";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  plugins: [sveltekit(), tailwindcss(), enhancedImages(), VitePWA({ registerType: "autoUpdate" })],
  build: { target: "esnext" },
});
