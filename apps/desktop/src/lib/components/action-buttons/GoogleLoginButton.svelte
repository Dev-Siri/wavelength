<script lang="ts">
  import { page } from "$app/state";
  import { PUBLIC_BACKEND_URL } from "$env/static/public";
  import { z } from "zod";

  import { localStorageKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte";
  import { backendClient } from "$lib/utils/query-client";
  import { authUserSchema } from "$lib/utils/validation/auth";

  import { Button } from "../ui/button";
  import GoogleLogo from "../vectors/GoogleLogo.svelte";

  const authCode = page.url.searchParams.get("code");

  $effect(() => {
    async function consumeAuthToken() {
      if (!authCode || userStore.authToken) return;
      const { authToken } = await backendClient(
        "/auth/token/consume",
        z.object({ authToken: z.string() }),
        { searchParams: { code: authCode } },
      );

      localStorage.setItem(localStorageKeys.authToken, authToken);
      userStore.authToken = authToken;

      const authUser = await backendClient("/auth/profile", authUserSchema, {
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });

      localStorage.setItem(localStorageKeys.authUser, JSON.stringify(authUser));
      userStore.user = authUser;

      const url = new URL(window.location.href);
      url.searchParams.delete("code");

      history.replaceState({}, "", url.toString());
    }

    consumeAuthToken();
  });

  const handleSignIn = () =>
    (location.href = `${PUBLIC_BACKEND_URL}/auth/login/google?redirectUri=${location.href}`);
</script>

<Button onclick={handleSignIn} class="gap-1">
  <GoogleLogo />
  <span class="hidden sm:block">Sign in with Google</span>
</Button>
