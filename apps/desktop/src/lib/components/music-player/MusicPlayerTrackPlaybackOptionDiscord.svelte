<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";
  import { toast } from "svelte-sonner";

  import { clearDrpc, startDrpc, updateDrpcActivity } from "$lib/ipc/drpc";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import settingsStore from "$lib/stores/settings.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { punctuatify } from "$lib/utils/format";

  import { buttonVariants } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";
  import DiscordLogo from "../vectors/DiscordLogo.svelte";

  async function toggleDiscordMode() {
    if (!isTauri()) return;

    try {
      if (musicInterfaceStore.isDrpcConnected) {
        await clearDrpc();
        musicInterfaceStore.isDrpcConnected = false;
        return;
      }

      await startDrpc();
      if (musicPlayer.queue.playingNow && settingsStore.settings.discordMode) {
        await updateDrpcActivity({
          state: punctuatify(musicPlayer.queue.playingNow.artists.map(artist => artist.title)),
          details: musicPlayer.queue.playingNow.title,
          currentTime: musicPlayer.currentTime,
          totalTime: musicPlayer.duration,
          thumbnail: musicPlayer.queue.playingNow.thumbnail,
        });
      }

      musicInterfaceStore.isDrpcConnected = true;
    } catch {
      toast.error("Discord Presence could not be broadcasted. Is the Discord app running?");
    }
  }

  $effect(() => {
    if (!settingsStore.settings.discordMode) {
      musicInterfaceStore.isDrpcConnected = false;
      clearDrpc();
    }
  });
</script>

{#if isTauri() && settingsStore.settings.discordMode}
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({
        variant: "ghost",
        class: `w-fit px-3 rounded-full ${musicInterfaceStore.isDrpcConnected ? "" : "opacity-50"}`,
      })}
      onclick={toggleDiscordMode}
    >
      <DiscordLogo />
    </Tooltip.Trigger>
    <Tooltip.Content class="z-9999">
      <p>
        {musicInterfaceStore.isDrpcConnected ? "Disable Discord Mode" : "Enable Discord Mode"}
      </p>
    </Tooltip.Content>
  </Tooltip.Root>
{/if}
