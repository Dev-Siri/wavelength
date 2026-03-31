<script>
  import { blur } from "svelte/transition";

  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import Logo from "./Logo.svelte";

  let isHoveringBadge = $state(false);
</script>

{#if musicPlayer.streamMetadata && musicPlayer.streamMetadata.bitrate >= 256_000}
  <div
    class={`relative flex items-center select-none justify-center z-10 text-white gap-2 w-fit ${"bg-secondary/50 backdrop-blur-2xl rounded-full py-0.5 px-3.5 metal-badge"}`}
    role="presentation"
    onmouseenter={() => (isHoveringBadge = true)}
    onmouseleave={() => (isHoveringBadge = false)}
  >
    <Logo class="text-sm font-medium" />
    {#key isHoveringBadge}
      <span in:blur class="text-xs text-center text-secondary-foreground/90 font-semibold mt-0.5">
        {#if isHoveringBadge}
          {#if musicPlayer.streamMetadata?.bitrate === 1_520_000}
            24-bit FLAC
          {:else if musicPlayer.streamMetadata?.bitrate === 1_411_000}
            16-bit FLAC
          {:else if musicPlayer.streamMetadata?.bitrate === 320_000}
            320kb/s AAC
          {:else}
            256kb/s AAC
          {/if}
        {:else if (musicPlayer.streamMetadata?.bitrate ?? 0) >= 1_200_000}
          Hi-Fi Lossless
        {:else if musicPlayer.streamMetadata?.bitrate === 320_000}
          Hi-Fi Audio
        {:else}
          HD Audio
        {/if}
      </span>
    {/key}
  </div>
{/if}

<style>
  .metal-badge::before {
    content: "";
    position: absolute;
    inset: -2px;
    border-radius: inherit;
    z-index: -1;
    background: linear-gradient(90deg, #6868688e, #9c9c9c80, #b6b6b65b, #9e9e9e6a);
    background-size: 300% 100%;
    filter: blur(4px);
    animation: glow-swing 3s infinite alternate;
  }

  @keyframes glow-swing {
    0% {
      background-position: 0% 50%;
    }
    50% {
      background-position: 100% 50%;
    }
    100% {
      background-position: 0% 50%;
    }
  }
</style>
