/// <reference lib="webworker" />

import { clientsClaim } from "workbox-core";
import { cleanupOutdatedCaches, precacheAndRoute } from "workbox-precaching";
import { registerRoute } from "workbox-routing";
import { StaleWhileRevalidate } from "workbox-strategies";

const manifest = [
  { url: "/_app/immutable/start.js", revision: "1" },
  { url: "/_app/immutable/chunks/index.js", revision: "1" },
  { url: "/_app/assets/logo.png", revision: "1" },
  { url: "/index.html", revision: "1" },
];

precacheAndRoute(manifest);
cleanupOutdatedCaches();
clientsClaim();
registerRoute(
  ({ request }) => request.destination === "image",
  new StaleWhileRevalidate({
    cacheName: "images-cache",
  }),
);
