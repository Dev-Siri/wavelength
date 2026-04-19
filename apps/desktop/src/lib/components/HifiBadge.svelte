<script>
  import { blur } from "svelte/transition";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import Logo from "./Logo.svelte";

  let isHoveringBadge = $state(false);

  const bitrate = $derived(musicPlayer.currentStream?.metadata.bitrate);
  const sampleRate = $derived(musicPlayer.currentStream?.source.sampleRate ?? 44_100);
</script>

{#if bitrate && bitrate >= 256_000}
  <div
    class="relative flex items-center select-none justify-center z-10 text-white gap-2 w-fit bg-white/10 backdrop-blur-xl border border-white/15 rounded-full py-px px-3.5 metal-badge"
    role="presentation"
    onmouseenter={() => (isHoveringBadge = true)}
    onmouseleave={() => (isHoveringBadge = false)}
  >
    <Logo class="text-[10px] mt-px font-medium" />
    {#key isHoveringBadge}
      <span
        in:blur
        class="text-[8px] tracking-wide font-medium text-center text-secondary-foreground/90 mt-0.5"
      >
        {#if isHoveringBadge}
          {#if bitrate === 1_520_000}
            24-bit/{(sampleRate / 1000).toFixed(1).replace(".0", "")}kHz FLAC
          {:else if bitrate === 1_411_000}
            16-bit/44.1kHz FLAC
          {:else if bitrate === 320_000}
            320kb/s AAC
          {:else}
            256kb/s AAC
          {/if}
        {:else if bitrate >= 1_200_000}
          Hi-Fi Lossless
        {:else if bitrate === 320_000}
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
    background: linear-gradient(
      120deg,
      rgba(255, 255, 255, 0.25),
      rgba(180, 180, 180, 0.15),
      rgba(255, 255, 255, 0.1),
      rgba(120, 120, 120, 0.2)
    );
    background-size: 300% 100%;
    filter: blur(4px);
    animation: glow-swing 3s infinite alternate;
  }

  .metal-badge::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    pointer-events: none;

    background: linear-gradient(
      to bottom,
      rgba(255, 255, 255, 0.25),
      rgba(255, 255, 255, 0.05) 40%,
      transparent 60%
    );
  }

  @keyframes glow-swing {
    0% {
      background-position: 0% 50%;
      opacity: 0.7;
    }
    50% {
      background-position: 100% 50%;
      opacity: 1;
    }
    100% {
      background-position: 0% 50%;
      opacity: 0.8;
    }
  }
</style>
