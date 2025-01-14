import { SvelteKitAuth } from "@auth/sveltekit";
import Google from "@auth/sveltekit/providers/google";

import { PRIVATE_GOOGLE_CLIENT_ID, PRIVATE_GOOGLE_CLIENT_SECRET } from "$env/static/private";

export const { handle } = SvelteKitAuth({
  trustHost: true,
  providers: [
    Google({ clientId: PRIVATE_GOOGLE_CLIENT_ID, clientSecret: PRIVATE_GOOGLE_CLIENT_SECRET }),
  ],
});
