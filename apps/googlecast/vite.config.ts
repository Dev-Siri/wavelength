import { svelte } from "@sveltejs/vite-plugin-svelte";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [svelte(), tailwindcss()],
  resolve: {
    tsconfigPaths: true,
  },
  server: {
    port: 6457,
  },
  build: {
    cssMinify: false,
  },
});
