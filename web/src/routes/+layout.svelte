<script lang="ts">
  import { dev } from "$app/environment";
  import { injectAnalytics } from "@vercel/analytics/sveltekit";
  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import "../app.css";

  import userStore from "$lib/stores/user.svelte";

  import type { User } from "@auth/sveltekit";
  import type { Snippet } from "svelte";
  import type { LayoutData } from "./$types";

  injectAnalytics({ mode: dev ? "development" : "production" });
  injectSpeedInsights();

  const { children, data }: { children: Snippet; data: LayoutData } = $props();

  $effect(() => {
    userStore.user = data.session?.user as User | null;
  });
</script>

<svelte:head>
  <title>WaveLength</title>
  <meta name="description" content="Call this a glorified YouTube Music Wrapper." />
</svelte:head>

{@render children?.()}
