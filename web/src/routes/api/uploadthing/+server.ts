import { PRIVATE_UPLOADTHING_TOKEN } from "$env/static/private";
import { ourFileRouter } from "$lib/server/uploadthing";

import { createRouteHandler } from "uploadthing/server";

const handlers = createRouteHandler({
  router: ourFileRouter,
  config: {
    token: PRIVATE_UPLOADTHING_TOKEN,
  },
});

export { handlers as GET, handlers as POST };
