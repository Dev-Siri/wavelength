<script lang="ts">
  import { InfoIcon } from "@lucide/svelte";

  import settingsStore from "$lib/stores/settings.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import { compactify } from "$lib/utils/format";

  import { buttonVariants } from "../ui/button";
  import * as HoverCard from "../ui/hover-card";

  function getReadableCodec(codec: string) {
    if (codec === "aac") return " (AAC)";
    if (codec === "flac") return "";
    return ` (${codec.charAt(0).toUpperCase()}${codec.slice(1)})`;
  }

  function getReadableBitrate(bitrate: number, ext: string) {
    if (bitrate === 1_411_000) return `1,411kb/s • 16-bit • 44.1kHz (Hi-Fi Lossless, FLAC)`;
    if (bitrate === 1_520_000) return `1,520kb/s • 24-bit • 44.1kHz (Hi-Fi Lossless, FLAC)`;
    if (bitrate === 128) return `128kb/s (${ext.toUpperCase()})`;
    if (bitrate === 320_000) return `320kb/s • 44.1kHz (Hi-Fi ${ext.toUpperCase()})`;
    if (bitrate === 256_000) return `256kb/s • 44.1kHz (High Quality, ${ext.toUpperCase()})`;
    return `${compactify(bitrate)}kb/s (${ext.toUpperCase()})`;
  }
</script>

{#if settingsStore.settings.showStats}
  <HoverCard.Root>
    <HoverCard.Trigger
      class={buttonVariants({
        variant: "ghost",
        class: `w-fit px-3 ml-1 rounded-full ${musicPlayer.streamMetadata ? "" : "opacity-50 cursor-default hover:bg-transparent"}`,
      })}
    >
      <InfoIcon size={20} class="text-primary {musicPlayer.streamMetadata ? '' : 'opacity-50'}" />
    </HoverCard.Trigger>
    <HoverCard.Content class="z-9999 w-full {musicPlayer.streamMetadata ? '' : 'hidden'}">
      {#if musicPlayer.streamMetadata}
        {@const { bitrate, codec, ext, source } = musicPlayer.streamMetadata}
        <span class="text-xl mb-2 font-semibold select-none">Stream</span>
        <p>
          <code>
            {getReadableBitrate(bitrate, ext)}{getReadableCodec(codec.acodec ?? "none")}
          </code>
        </p>
        <p>
          <code>source: {source}</code>
        </p>
        {#if source.includes("Wavelength")}
          <p>
            <code>security: stream token (exp: 6 hours)</code>
          </p>
        {/if}
      {/if}
    </HoverCard.Content>
  </HoverCard.Root>
{/if}
