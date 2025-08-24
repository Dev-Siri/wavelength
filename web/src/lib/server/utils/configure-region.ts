import geoip from "geoip-lite";

import type { Cookies } from "@sveltejs/kit";

import { cookieKeys } from "$lib/constants/keys.js";

export default function configureRegion(cookies: Cookies, clientAddress: string) {
  let region = cookies.get(cookieKeys.region);

  if (!region) {
    const geo = geoip.lookup(clientAddress);
    const cookieOpts: Parameters<(typeof cookies)["set"]>[2] = {
      path: "/",
      expires: new Date(9999, 0, 1),
      httpOnly: false,
      secure: false,
    };

    if (!geo) {
      cookies.set(cookieKeys.region, "US", cookieOpts);
      region = "US";
    } else {
      cookies.set(cookieKeys.region, geo.country, cookieOpts);
      region = geo.country;
    }
  }

  return region;
}
