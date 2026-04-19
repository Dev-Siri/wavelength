<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";
  import { listen, type UnlistenFn } from "@tauri-apps/api/event";
  import { onMount, type Snippet } from "svelte";

  import { SETTINGS_EVENTS } from "$lib/constants/tauri";
  import { getSettings } from "$lib/ipc/settingsManager";
  import settingsStore from "$lib/stores/settings.svelte";

  const { children }: { children: Snippet } = $props();

  onMount(() => {
    async function fetchInitialSettings() {
      settingsStore.settings = await getSettings();
    }

    fetchInitialSettings();
  });

  onMount(() => {
    let unlisten: UnlistenFn | null = null;
    async function handleSettingsUpdate() {
      if (!isTauri()) return;

      unlisten = await listen(SETTINGS_EVENTS.update, async () => {
        const settings = await getSettings();
        settingsStore.settings = settings;
      });
    }

    handleSettingsUpdate();
    return () => {
      if (unlisten) unlisten();
    };
  });
</script>

{@render children?.()}
