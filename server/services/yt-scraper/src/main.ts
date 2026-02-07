import * as grpc from "@grpc/grpc-js";

import { ADDR_ALLOW_ALL, DEFAULT_PORT, env } from "@/config.js";
import { YTScraperService } from "@/gen/proto/yt_scraper.js";
import { ytScraperServer } from "@/server.js";

const port = Number(env.PORT || DEFAULT_PORT);
const address = env.ADDR || ADDR_ALLOW_ALL;

const server = new grpc.Server({
  "grpc.keepalive_time_ms": 120000,
  "grpc.keepalive_timeout_ms": 20000,
  "grpc.http2.min_time_between_pings_ms": 120000,
  "grpc.http2.max_pings_without_data": 0,
  "grpc.http2.max_ping_strikes": 0,
});
const bindAddress = `${address}:${port}`;

server.addService(YTScraperService, ytScraperServer);
server.bindAsync(
  bindAddress,
  grpc.ServerCredentials.createInsecure(),
  (error, port) => {
    if (error) return console.error("YtScraperService startup failed: ", error);
    console.log(`YtScraperService is listening on port: ${port}`);
  },
);

const postShutdown = () =>
  console.log("YtScraperService has been disconnected.");

process.on("SIGTERM", () => server.tryShutdown(postShutdown));
process.on("SIGINT", () => server.tryShutdown(postShutdown));
