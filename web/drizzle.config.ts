import { configDotenv } from "dotenv";
import { defineConfig } from "drizzle-kit";

configDotenv({ path: "./.env.local" });

export default defineConfig({
  schema: "./src/lib/db/schema.ts",
  dialect: "postgresql",
  out: "./drizzle",
  dbCredentials: {
    url: process.env.PRIVATE_DSN!,
  },
});
