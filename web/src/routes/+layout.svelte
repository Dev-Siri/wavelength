<script lang="ts">
  import { dev } from "$app/environment";
  import { injectAnalytics } from "@vercel/analytics/sveltekit";
  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import "../app.css";

  import userStore, { getAuthToken } from "$lib/stores/user.svelte.js";

  import type { User } from "@auth/sveltekit";
  import type { Snippet } from "svelte";
  import type { LayoutData } from "./$types.js";

  injectAnalytics({ mode: dev ? "development" : "production" });
  injectSpeedInsights();

  const { children, data }: { children: Snippet; data: LayoutData } = $props();

  $effect(() => {
    async function setupSession() {
      userStore.user = data.session?.user as User | null;

      if (userStore.authToken || !data.session?.user) return;

      const token = await getAuthToken(data.session?.user);
      userStore.authToken = token;
    }

    setupSession();
  });
</script>

<svelte:head>
  <title>WavLen</title>
</svelte:head>

{@render children?.()}
