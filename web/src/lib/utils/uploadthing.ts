import { generateSvelteHelpers } from "@uploadthing/svelte";

import type { OurFileRouter } from "$lib/server/uploadthing.js";

export const { createUploader, createUploadThing } = generateSvelteHelpers<OurFileRouter>();
