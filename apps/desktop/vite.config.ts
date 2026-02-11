import { sveltekit } from "@sveltejs/kit/vite";
import tailwindcss from "@tailwindcss/vite";
import { SvelteKitPWA } from "@vite-pwa/sveltekit";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    sveltekit(),
    tailwindcss(),
    SvelteKitPWA({
      includeAssets: ["pwa/vector.svg", "pwa/192x192.png", "pwa/512x512.png"],
      manifest: {
        name: "WavLen",
        short_name: "WavLen",
        description: "Call this a glorified YouTube Music wrapper.",
        start_url: "/app",
        display: "standalone",
        theme_color: "#000000",
        icons: [
          {
            src: "pwa/vector.svg",
            sizes: "any",
            type: "image/svg+xml",
            purpose: "maskable",
          },
          {
            src: "pwa/192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "pwa/512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
        ],
      },
      strategies: "generateSW",
      workbox: {
        clientsClaim: true,
        skipWaiting: true,
      },
      devOptions: {
        enabled: true,
      },
    }),
  ],
  build: { target: "esnext" },
});
