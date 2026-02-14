<script lang="ts">
  import { dev } from "$app/environment";
  import { goto } from "$app/navigation";
  import { injectAnalytics } from "@vercel/analytics/sveltekit";
  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import "../app.css";

  import type { Snippet } from "svelte";

  import { localStorageKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";
  import { authUserSchema } from "$lib/utils/validation/auth";

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
    if (userStore.user) goto("/app");
  });
</script>

<svelte:head>
  <title>WavLen</title>
</svelte:head>

{@render children?.()}
