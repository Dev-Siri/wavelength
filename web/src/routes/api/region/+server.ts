import { json } from "@sveltejs/kit";

import configureRegion from "$lib/server/utils/configure-region.js";

export function GET({ cookies, getClientAddress }) {
  const region = configureRegion(cookies, getClientAddress());

  return json({
    success: true,
    data: region,
  });
}
