<script lang="ts">
  import { dev } from "$app/environment";
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";
  import { page } from "$app/state";
  import { injectAnalytics } from "@vercel/analytics/sveltekit";
  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import "../app.css";

  import type { Snippet } from "svelte";

  import { localStorageKeys } from "$lib/constants/keys";
  import { authUserSchema } from "$lib/schemas/auth";
  import userStore from "$lib/stores/user.svelte.js";

  injectAnalytics({ mode: dev ? "development" : "production" });
  injectSpeedInsights();

  const { children }: { children: Snippet } = $props();

  $effect(() => {
    function initializeAuth() {
      const storedUser = localStorage.getItem(localStorageKeys.authUser);
      const storedAuthToken = localStorage.getItem(localStorageKeys.authToken);

      userStore.authToken = storedAuthToken;
      if (!storedUser) return;

      const parsedUser = JSON.parse(storedUser);
      const validatedUser = authUserSchema.safeParse(parsedUser);

      if (validatedUser.success) userStore.user = validatedUser.data;
    }

    initializeAuth();
  });

  $effect(() => {
    if (page.url.pathname !== "/downloads") {
      if (userStore.user && !page.url.pathname.includes("/app")) goto(resolve("/app"));
    }
  });
</script>

<svelte:head>
  <title>WavLen</title>
</svelte:head>

{@render children?.()}
