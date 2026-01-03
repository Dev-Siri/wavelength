import * as grpc from "@grpc/grpc-js";

import { ADDR_ALLOW_ALL, DEFAULT_PORT, env } from "./config";
import { YTScraperService } from "./gen/proto/yt_scraper_grpc_pb";
import { ytScraperServer } from "./server";

const port = env.PORT || DEFAULT_PORT;
const address = env.ADDR || ADDR_ALLOW_ALL;

const server = new grpc.Server();
const bindAddress = `${address}:${port}`;

server.addService(YTScraperService, ytScraperServer);
server.bindAsync(
  bindAddress,
  grpc.ServerCredentials.createInsecure(),
  (error, port) => {
    if (error) return console.error("YtScraperService startup failed: ", error);
    console.log(`YtScraperService is listening on port: ${port}`);
  }
);
