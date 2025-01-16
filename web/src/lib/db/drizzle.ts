import { PRIVATE_DSN } from "$env/static/private";
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
// import { migrate } from "drizzle-orm/neon-http/migrator";

const sql = neon(PRIVATE_DSN);
const db = drizzle(sql);

// await migrate(db, { migrationsFolder: "drizzle" });

export default db;
