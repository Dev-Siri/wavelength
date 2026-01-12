import { z } from "zod";

export const DEFAULT_PORT = "8080";
export const ADDR_ALLOW_ALL = "0.0.0.0";

export const DEFAULT_CLIENT = "US";

const envConfig = z.object({
  PORT: z.string().nullish(),
  ADDR: z.string().nullish(),
  COOKIE: z.string().optional(),
});

export const env = envConfig.parse(process.env);
