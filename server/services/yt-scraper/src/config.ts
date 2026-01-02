import { z } from "zod";

export const DEFAULT_PORT = "8080";
export const ADDR_ALLOW_ALL = "0.0.0.0";

const envConfig = z.object({
  PORT: z.string().nullish(),
  ADDR: z.string().nullish(),
});

export const env = envConfig.parse(process.env);
