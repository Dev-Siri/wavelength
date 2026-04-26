import { svelte } from "@sveltejs/vite-plugin-svelte";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  // base: process.env.VITE_DEV
  //   ? undefined
  //   : "https://wavelength-googlecast.vercel.app",
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
