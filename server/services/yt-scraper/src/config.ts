import { z } from "zod";

export const DEFAULT_PORT = "8080";
export const ADDR_ALLOW_ALL = "0.0.0.0";

export const DEFAULT_CLIENT = "US";

const envConfig = z.object({
  PORT: z.string().nullish(),
  ADDR: z.string().nullish(),
  UPSTASH_REDIS_REST_URL: z.string(),
  UPSTASH_REDIS_REST_TOKEN: z.string(),
});

export const env = envConfig.parse(process.env);
