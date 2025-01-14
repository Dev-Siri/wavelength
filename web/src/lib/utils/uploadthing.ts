import { generateSvelteHelpers } from "@uploadthing/svelte";

import type { OurFileRouter } from "$lib/server/uploadthing";

export const { createUploader, createUploadThing } = generateSvelteHelpers<OurFileRouter>();
